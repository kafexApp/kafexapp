// supabase/functions/verify-email-redirect/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

serve(async (req) => {
  try {
    // Extrair o token da URL
    const url = new URL(req.url);
    const token = url.searchParams.get("token");

    if (!token) {
      return new Response(
        `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Erro - Kafex</title>
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              margin: 0;
              background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%);
            }
            .container {
              background: white;
              padding: 40px;
              border-radius: 12px;
              box-shadow: 0 4px 20px rgba(0,0,0,0.2);
              text-align: center;
              max-width: 400px;
            }
            h1 { color: #6B4423; margin-bottom: 20px; }
            p { color: #666; line-height: 1.6; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>❌ Token Inválido</h1>
            <p>O link de verificação está incompleto ou inválido.</p>
            <p>Por favor, verifique o email novamente.</p>
          </div>
        </body>
        </html>
        `,
        {
          headers: { "Content-Type": "text/html; charset=utf-8" },
          status: 400,
        }
      );
    }

    console.log(`🔗 Processando verificação com token: ${token}`);

    // Verificar o token diretamente na Edge Function
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { data: verification, error: fetchError } = await supabaseClient
      .from("email_verification")
      .select("*")
      .eq("token", token)
      .single();

    if (fetchError || !verification) {
      console.error("❌ Token não encontrado:", fetchError);
      return new Response(
        `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Token Inválido - Kafex</title>
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              margin: 0;
              background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%);
            }
            .container {
              background: white;
              padding: 40px;
              border-radius: 12px;
              box-shadow: 0 4px 20px rgba(0,0,0,0.2);
              text-align: center;
              max-width: 400px;
            }
            h1 { color: #6B4423; margin-bottom: 20px; }
            p { color: #666; line-height: 1.6; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>❌ Token Inválido</h1>
            <p>O link de verificação não é válido ou já foi usado.</p>
          </div>
        </body>
        </html>
        `,
        {
          headers: { "Content-Type": "text/html; charset=utf-8" },
          status: 404,
        }
      );
    }

    // Verificar se já foi verificado
    if (verification.verified) {
      return new Response(
        `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Sucesso - Kafex</title>
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              margin: 0;
              background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%);
            }
            .container {
              background: white;
              padding: 40px;
              border-radius: 12px;
              box-shadow: 0 4px 20px rgba(0,0,0,0.2);
              text-align: center;
              max-width: 400px;
            }
            h1 { color: #28a745; margin-bottom: 20px; }
            p { color: #666; line-height: 1.6; }
            .button {
              display: inline-block;
              background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%);
              color: white;
              padding: 12px 30px;
              border-radius: 6px;
              text-decoration: none;
              margin-top: 20px;
              font-weight: bold;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>✅ Email Já Verificado!</h1>
            <p>Seu email já foi verificado anteriormente.</p>
            <p>Você já pode usar o app Kafex normalmente!</p>
          </div>
        </body>
        </html>
        `,
        {
          headers: { "Content-Type": "text/html; charset=utf-8" },
          status: 200,
        }
      );
    }

    // Verificar se expirou
    const now = new Date();
    const expiresAt = new Date(verification.expires_at);

    if (now > expiresAt) {
      return new Response(
        `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Link Expirado - Kafex</title>
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              display: flex;
              justify-content: center;
              align-items: center;
              min-height: 100vh;
              margin: 0;
              background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%);
            }
            .container {
              background: white;
              padding: 40px;
              border-radius: 12px;
              box-shadow: 0 4px 20px rgba(0,0,0,0.2);
              text-align: center;
              max-width: 400px;
            }
            h1 { color: #dc3545; margin-bottom: 20px; }
            p { color: #666; line-height: 1.6; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>⏱️ Link Expirado</h1>
            <p>Este link de verificação expirou.</p>
            <p>Por favor, faça login no app e solicite um novo email de verificação.</p>
          </div>
        </body>
        </html>
        `,
        {
          headers: { "Content-Type": "text/html; charset=utf-8" },
          status: 400,
        }
      );
    }

    // Marcar como verificado
    const { error: updateTokenError } = await supabaseClient
      .from("email_verification")
      .update({
        verified: true,
        verified_at: now.toISOString(),
      })
      .eq("token", token);

    if (updateTokenError) {
      console.error("❌ Erro ao atualizar token:", updateTokenError);
    }

    // Atualizar usuário
    const { error: updateUserError } = await supabaseClient
      .from("usuario_perfil")
      .update({
        email_verificado: true,
        atualizado_em: now.toISOString(),
      })
      .eq("ref", verification.user_ref);

    if (updateUserError) {
      console.error("⚠️ Aviso ao atualizar usuário:", updateUserError);
    }

    console.log("✅ Email verificado com sucesso!");

    // Página de sucesso
    return new Response(
      `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Email Verificado - Kafex</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%);
          }
          .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            text-align: center;
            max-width: 400px;
          }
          .icon {
            width: 80px;
            height: 80px;
            background: #28a745;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 40px;
          }
          h1 { color: #28a745; margin-bottom: 20px; }
          p { color: #666; line-height: 1.6; margin-bottom: 15px; }
          .note { font-size: 14px; color: #999; margin-top: 30px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="icon">✓</div>
          <h1>Email Verificado!</h1>
          <p><strong>Parabéns!</strong> Seu email foi verificado com sucesso.</p>
          <p>Agora você já pode usar o app Kafex normalmente!</p>
          <p class="note">Você pode fechar esta página e voltar ao app.</p>
        </div>
      </body>
      </html>
      `,
      {
        headers: { "Content-Type": "text/html; charset=utf-8" },
        status: 200,
      }
    );

  } catch (error) {
    console.error("❌ Erro:", error);
    
    return new Response(
      `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Erro - Kafex</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%);
          }
          .container {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.2);
            text-align: center;
            max-width: 400px;
          }
          h1 { color: #6B4423; margin-bottom: 20px; }
          p { color: #666; line-height: 1.6; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>❌ Erro</h1>
          <p>Ocorreu um erro ao processar sua solicitação.</p>
          <p>Por favor, tente novamente mais tarde.</p>
        </div>
      </body>
      </html>
      `,
      {
        headers: { "Content-Type": "text/html; charset=utf-8" },
        status: 500,
      }
    );
  }
});