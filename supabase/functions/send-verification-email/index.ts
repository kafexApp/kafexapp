// supabase/functions/send-verification-email/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const BREVO_API_KEY = "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";
const SENDER_EMAIL = "noreply@kafex.com.br";
const SENDER_NAME = "Kafex App";
const APP_URL = "https://link.kafex.com.br/verify-email"; // ✅ ATUALIZADO

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  userRef: string;
  email: string;
  nomeExibicao: string;
  type: "verification" | "welcome";
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

    const { userRef, email, nomeExibicao, type } = await req.json() as RequestBody;

    console.log(`📧 Processando email tipo: ${type} para ${email}`);

    if (type === "verification") {
      // Gerar token único para verificação
      const token = crypto.randomUUID();
      const expiresAt = new Date();
      expiresAt.setHours(expiresAt.getHours() + 24); // Token expira em 24 horas

      // Salvar token no banco
      const { error: insertError } = await supabaseClient
        .from("email_verification")
        .insert({
          user_ref: userRef,
          email: email,
          token: token,
          expires_at: expiresAt.toISOString(),
          verified: false,
          attempts: 0,
        });

      if (insertError) {
        console.error("❌ Erro ao salvar token:", insertError);
        throw insertError;
      }

      // Link de verificação - ✅ ATUALIZADO
      const verificationLink = `${APP_URL}?token=${token}`;

      // Template HTML do email de verificação
      const htmlContent = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Verifique seu email - Kafex</title>
        </head>
        <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4;">
          <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f4f4; padding: 20px;">
            <tr>
              <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                  <!-- Header com logo -->
                  <tr>
                    <td style="background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%); padding: 40px 20px; text-align: center;">
                      <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: bold;">☕ Kafex</h1>
                    </td>
                  </tr>
                  
                  <!-- Conteúdo -->
                  <tr>
                    <td style="padding: 40px 30px;">
                      <h2 style="color: #333333; margin: 0 0 20px 0; font-size: 24px;">Olá, ${nomeExibicao}! 👋</h2>
                      
                      <p style="color: #666666; line-height: 1.6; margin: 0 0 20px 0; font-size: 16px;">
                        Bem-vindo ao <strong>Kafex</strong>! Estamos muito felizes em ter você conosco.
                      </p>
                      
                      <p style="color: #666666; line-height: 1.6; margin: 0 0 30px 0; font-size: 16px;">
                        Para começar a explorar as melhores cafeterias e compartilhar suas experiências, 
                        precisamos verificar seu endereço de email.
                      </p>
                      
                      <!-- Botão -->
                      <table width="100%" cellpadding="0" cellspacing="0">
                        <tr>
                          <td align="center" style="padding: 20px 0;">
                            <a href="${verificationLink}" 
                               style="background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%); 
                                      color: #ffffff; 
                                      text-decoration: none; 
                                      padding: 16px 40px; 
                                      border-radius: 6px; 
                                      display: inline-block; 
                                      font-weight: bold;
                                      font-size: 16px;
                                      box-shadow: 0 4px 6px rgba(107, 68, 35, 0.3);">
                              ✉️ Verificar Email
                            </a>
                          </td>
                        </tr>
                      </table>
                      
                      <p style="color: #999999; line-height: 1.6; margin: 30px 0 0 0; font-size: 14px;">
                        Ou copie e cole este link no seu navegador:<br>
                        <a href="${verificationLink}" style="color: #6B4423; word-break: break-all;">${verificationLink}</a>
                      </p>
                      
                      <p style="color: #999999; line-height: 1.6; margin: 20px 0 0 0; font-size: 14px;">
                        ⏱️ Este link expira em 24 horas.
                      </p>
                    </td>
                  </tr>
                  
                  <!-- Footer -->
                  <tr>
                    <td style="background-color: #f8f8f8; padding: 30px; text-align: center; border-top: 1px solid #eeeeee;">
                      <p style="color: #999999; margin: 0 0 10px 0; font-size: 14px;">
                        Se você não criou uma conta no Kafex, ignore este email.
                      </p>
                      <p style="color: #cccccc; margin: 0; font-size: 12px;">
                        © ${new Date().getFullYear()} Kafex. Todos os direitos reservados.
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
        </html>
      `;

      // Enviar email via Brevo
      const brevoResponse = await fetch("https://api.brevo.com/v3/smtp/email", {
        method: "POST",
        headers: {
          "accept": "application/json",
          "api-key": BREVO_API_KEY,
          "content-type": "application/json",
        },
        body: JSON.stringify({
          sender: {
            name: SENDER_NAME,
            email: SENDER_EMAIL,
          },
          to: [
            {
              email: email,
              name: nomeExibicao,
            },
          ],
          subject: "Verifique seu email - Kafex ☕",
          htmlContent: htmlContent,
        }),
      });

      if (!brevoResponse.ok) {
        const errorData = await brevoResponse.text();
        console.error("❌ Erro Brevo:", errorData);
        throw new Error(`Erro ao enviar email: ${errorData}`);
      }

      console.log("✅ Email de verificação enviado com sucesso!");

      return new Response(
        JSON.stringify({ success: true, message: "Email de verificação enviado!" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
      );

    } else if (type === "welcome") {
      // Template HTML do email de boas-vindas
      const htmlContent = `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Bem-vindo ao Kafex!</title>
        </head>
        <body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4;">
          <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f4f4; padding: 20px;">
            <tr>
              <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                  <!-- Header -->
                  <tr>
                    <td style="background: linear-gradient(135deg, #6B4423 0%, #8B5A3C 100%); padding: 40px 20px; text-align: center;">
                      <h1 style="color: #ffffff; margin: 0; font-size: 32px; font-weight: bold;">☕ Bem-vindo ao Kafex!</h1>
                    </td>
                  </tr>
                  
                  <!-- Conteúdo -->
                  <tr>
                    <td style="padding: 40px 30px;">
                      <h2 style="color: #333333; margin: 0 0 20px 0; font-size: 24px;">Olá, ${nomeExibicao}! 🎉</h2>
                      
                      <p style="color: #666666; line-height: 1.6; margin: 0 0 20px 0; font-size: 16px;">
                        Parabéns! Seu email foi verificado com sucesso e sua conta está ativa.
                      </p>
                      
                      <p style="color: #666666; line-height: 1.6; margin: 0 0 30px 0; font-size: 16px;">
                        Agora você pode aproveitar ao máximo o Kafex:
                      </p>
                      
                      <!-- Lista de benefícios -->
                      <table width="100%" cellpadding="0" cellspacing="0" style="margin: 0 0 30px 0;">
                        <tr>
                          <td style="padding: 15px; background-color: #f8f8f8; border-radius: 6px; margin-bottom: 10px;">
                            <p style="margin: 0; color: #333333; font-size: 16px;">
                              ☕ <strong>Descubra</strong> as melhores cafeterias da sua região
                            </p>
                          </td>
                        </tr>
                        <tr><td style="height: 10px;"></td></tr>
                        <tr>
                          <td style="padding: 15px; background-color: #f8f8f8; border-radius: 6px;">
                            <p style="margin: 0; color: #333333; font-size: 16px;">
                              📝 <strong>Compartilhe</strong> suas experiências com a comunidade
                            </p>
                          </td>
                        </tr>
                        <tr><td style="height: 10px;"></td></tr>
                        <tr>
                          <td style="padding: 15px; background-color: #f8f8f8; border-radius: 6px;">
                            <p style="margin: 0; color: #333333; font-size: 16px;">
                              ⭐ <strong>Avalie</strong> e ajude outros amantes de café
                            </p>
                          </td>
                        </tr>
                        <tr><td style="height: 10px;"></td></tr>
                        <tr>
                          <td style="padding: 15px; background-color: #f8f8f8; border-radius: 6px;">
                            <p style="margin: 0; color: #333333; font-size: 16px;">
                              📍 <strong>Salve</strong> seus lugares favoritos
                            </p>
                          </td>
                        </tr>
                      </table>
                      
                      <p style="color: #666666; line-height: 1.6; margin: 0 0 30px 0; font-size: 16px;">
                        Estamos aqui para tornar sua jornada cafeinada ainda melhor! ☕
                      </p>
                    </td>
                  </tr>
                  
                  <!-- Footer -->
                  <tr>
                    <td style="background-color: #f8f8f8; padding: 30px; text-align: center; border-top: 1px solid #eeeeee;">
                      <p style="color: #999999; margin: 0 0 10px 0; font-size: 14px;">
                        Precisa de ajuda? Entre em contato conosco em <a href="mailto:suporte@kafex.com.br" style="color: #6B4423;">suporte@kafex.com.br</a>
                      </p>
                      <p style="color: #cccccc; margin: 0; font-size: 12px;">
                        © ${new Date().getFullYear()} Kafex. Todos os direitos reservados.
                      </p>
                    </td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </body>
        </html>
      `;

      // Enviar email de boas-vindas via Brevo
      const brevoResponse = await fetch("https://api.brevo.com/v3/smtp/email", {
        method: "POST",
        headers: {
          "accept": "application/json",
          "api-key": BREVO_API_KEY,
          "content-type": "application/json",
        },
        body: JSON.stringify({
          sender: {
            name: SENDER_NAME,
            email: SENDER_EMAIL,
          },
          to: [
            {
              email: email,
              name: nomeExibicao,
            },
          ],
          subject: "Bem-vindo ao Kafex! ☕🎉",
          htmlContent: htmlContent,
        }),
      });

      if (!brevoResponse.ok) {
        const errorData = await brevoResponse.text();
        console.error("❌ Erro Brevo:", errorData);
        throw new Error(`Erro ao enviar email: ${errorData}`);
      }

      console.log("✅ Email de boas-vindas enviado com sucesso!");

      return new Response(
        JSON.stringify({ success: true, message: "Email de boas-vindas enviado!" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
      );
    }

    return new Response(
      JSON.stringify({ success: false, message: "Tipo de email inválido" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
    );

  } catch (error) {
    console.error("❌ Erro:", error);
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});