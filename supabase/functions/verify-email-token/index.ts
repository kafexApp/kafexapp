// supabase/functions/verify-email-token/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  token: string;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { token } = await req.json() as RequestBody;

    if (!token) {
      return new Response(
        JSON.stringify({ success: false, message: "Token não fornecido" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    console.log(`🔍 Verificando token: ${token}`);

    // Buscar token no banco
    const { data: verification, error: fetchError } = await supabaseClient
      .from("email_verification")
      .select("*")
      .eq("token", token)
      .single();

    if (fetchError || !verification) {
      console.error("❌ Token não encontrado:", fetchError);
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: "Token inválido ou não encontrado" 
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 404 }
      );
    }

    // Verificar se já foi verificado
    if (verification.verified) {
      console.log("⚠️ Email já verificado anteriormente");
      return new Response(
        JSON.stringify({ 
          success: true, 
          message: "Email já foi verificado anteriormente",
          alreadyVerified: true
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
      );
    }

    // Verificar se o token expirou
    const now = new Date();
    const expiresAt = new Date(verification.expires_at);

    if (now > expiresAt) {
      console.error("❌ Token expirado");
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: "Token expirado. Solicite um novo email de verificação.",
          expired: true
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    // Atualizar token como verificado
    const { error: updateTokenError } = await supabaseClient
      .from("email_verification")
      .update({
        verified: true,
        verified_at: now.toISOString(),
      })
      .eq("token", token);

    if (updateTokenError) {
      console.error("❌ Erro ao atualizar token:", updateTokenError);
      throw updateTokenError;
    }

    // Atualizar usuário no usuario_perfil (marcar email como verificado)
    const { error: updateUserError } = await supabaseClient
      .from("usuario_perfil")
      .update({
        email_verificado: true,
        atualizado_em: now.toISOString(),
      })
      .eq("ref", verification.user_ref);

    if (updateUserError) {
      console.error("⚠️ Aviso ao atualizar usuário:", updateUserError);
      // Não falha a verificação se der erro aqui
    }

    console.log("✅ Email verificado com sucesso!");

    return new Response(
      JSON.stringify({ 
        success: true, 
        message: "Email verificado com sucesso!",
        userRef: verification.user_ref,
        email: verification.email
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    );

  } catch (error) {
    console.error("❌ Erro:", error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});