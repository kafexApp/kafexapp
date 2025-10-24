#!/bin/bash

# Script para corrigir imports do app_routes.dart
# Substitui todas as variações de imports por package:kafex/config/app_routes.dart

echo "🔧 Corrigindo imports do app_routes.dart..."
echo ""

# Lista de arquivos que precisam ser corrigidos
files=(
  "lib/screens/welcome_screen.dart"
  "lib/screens/login_screen.dart"
  "lib/ui/create_account/widgets/create_account.dart"
  "lib/widgets/custom_bottom_navbar.dart"
  "lib/widgets/custom_app_bar.dart"
  "lib/ui/home/widgets/welcome_section.dart"
  "lib/ui/notifications/widgets/notifications_screen.dart"
  "lib/ui/user_profile/widgets/user_profile_screen.dart"
  "lib/ui/posts/widgets/feed_post_widget.dart"
  "lib/ui/posts/widgets/base_post_widget.dart"
  "lib/widgets/common/user_avatar.dart"
)

# Contador de arquivos processados
count=0

# Processar cada arquivo
for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    echo "✅ Corrigindo: $file"
    
    # Substituir import (funciona em Mac e Linux)
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      sed -i '' "s|import.*routes/app_routes\.dart.*|import 'package:kafex/config/app_routes.dart';|g" "$file"
    else
      # Linux
      sed -i "s|import.*routes/app_routes\.dart.*|import 'package:kafex/config/app_routes.dart';|g" "$file"
    fi
    
    ((count++))
  else
    echo "⚠️  Arquivo não encontrado: $file"
  fi
done

echo ""
echo "🎉 Concluído! $count arquivo(s) corrigido(s)."
echo ""
echo "📋 Próximos passos:"
echo "   1. flutter clean"
echo "   2. flutter pub get"
echo "   3. flutter run"