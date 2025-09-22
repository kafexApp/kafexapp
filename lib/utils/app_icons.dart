import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Classe centralizada de ícones do Kafex usando Phosphor Regular
class AppIcons {
  
  // =============================================================================
  // 🧭 NAVEGAÇÃO E DIREÇÕES
  // =============================================================================
  
  static PhosphorIconData get home => PhosphorIcons.house(PhosphorIconsStyle.regular);
  static PhosphorIconData get homeFill => PhosphorIcons.house(PhosphorIconsStyle.fill);
  static PhosphorIconData get back => PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular);
  static PhosphorIconData get forward => PhosphorIcons.arrowRight(PhosphorIconsStyle.regular);
  static PhosphorIconData get up => PhosphorIcons.arrowUp(PhosphorIconsStyle.regular);
  static PhosphorIconData get down => PhosphorIcons.arrowDown(PhosphorIconsStyle.regular);
  static PhosphorIconData get close => PhosphorIcons.x(PhosphorIconsStyle.regular);
  static PhosphorIconData get menu => PhosphorIcons.list(PhosphorIconsStyle.regular);
  
  // Chevrons (setas menores/decorativas)
  static PhosphorIconData get chevronUp => PhosphorIcons.caretUp(PhosphorIconsStyle.regular);
  static PhosphorIconData get chevronDown => PhosphorIcons.caretDown(PhosphorIconsStyle.regular);
  static PhosphorIconData get chevronLeft => PhosphorIcons.caretLeft(PhosphorIconsStyle.regular);
  static PhosphorIconData get chevronRight => PhosphorIcons.caretRight(PhosphorIconsStyle.regular);

  // Menu de opções (3 pontos)
  static PhosphorIconData get dotsThree => PhosphorIcons.dotsThree(PhosphorIconsStyle.regular);
  static PhosphorIconData get dotsThreeVertical => PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.regular);

  // =============================================================================
  // ☕ CAFÉ E ESTABELECIMENTOS
  // =============================================================================
  
  static PhosphorIconData get coffee => PhosphorIcons.coffee(PhosphorIconsStyle.regular);
  static PhosphorIconData get coffeeFill => PhosphorIcons.coffee(PhosphorIconsStyle.fill);
  static PhosphorIconData get coffeeCup => PhosphorIcons.coffee(PhosphorIconsStyle.regular);
  static PhosphorIconData get storefront => PhosphorIcons.storefront(PhosphorIconsStyle.regular);
  static PhosphorIconData get storefrontFill => PhosphorIcons.storefront(PhosphorIconsStyle.fill);
  static PhosphorIconData get wine => PhosphorIcons.wine(PhosphorIconsStyle.regular);
  
  // =============================================================================
  // 📍 LOCALIZAÇÃO E MAPAS
  // =============================================================================
  
  static PhosphorIconData get location => PhosphorIcons.mapPin(PhosphorIconsStyle.regular);
  static PhosphorIconData get locationFill => PhosphorIcons.mapPin(PhosphorIconsStyle.fill);
  static PhosphorIconData get map => PhosphorIcons.mapTrifold(PhosphorIconsStyle.regular);
  static PhosphorIconData get mapTrifold => PhosphorIcons.mapTrifold(PhosphorIconsStyle.regular);
  static PhosphorIconData get compass => PhosphorIcons.compass(PhosphorIconsStyle.regular);
  static PhosphorIconData get navigate => PhosphorIcons.compass(PhosphorIconsStyle.regular);
  static PhosphorIconData get navigation => PhosphorIcons.compass(PhosphorIconsStyle.regular);

  // =============================================================================
  // 🔍 BUSCA E FILTROS
  // =============================================================================
  
  static PhosphorIconData get search => PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular);
  static PhosphorIconData get filter => PhosphorIcons.funnel(PhosphorIconsStyle.regular);
  static PhosphorIconData get filterFill => PhosphorIcons.funnel(PhosphorIconsStyle.fill);
  static PhosphorIconData get sliders => PhosphorIcons.sliders(PhosphorIconsStyle.regular);

  // =============================================================================
  // 💖 INTERAÇÕES SOCIAIS
  // =============================================================================
  
  static PhosphorIconData get heart => PhosphorIcons.heart(PhosphorIconsStyle.regular);
  static PhosphorIconData get heartFill => PhosphorIcons.heart(PhosphorIconsStyle.fill); // CORRIGIDO para Fill
  static PhosphorIconData get star => PhosphorIcons.star(PhosphorIconsStyle.regular);
  static PhosphorIconData get starFill => PhosphorIcons.star(PhosphorIconsStyle.fill);
  static PhosphorIconData get thumbsUp => PhosphorIcons.thumbsUp(PhosphorIconsStyle.regular);
  static PhosphorIconData get thumbsUpFill => PhosphorIcons.thumbsUp(PhosphorIconsStyle.fill);
  static PhosphorIconData get thumbsDown => PhosphorIcons.thumbsDown(PhosphorIconsStyle.regular);
  static PhosphorIconData get share => PhosphorIcons.shareNetwork(PhosphorIconsStyle.regular);
  static PhosphorIconData get bookmark => PhosphorIcons.bookmark(PhosphorIconsStyle.regular);
  static PhosphorIconData get bookmarkFill => PhosphorIcons.bookmark(PhosphorIconsStyle.fill);

  // =============================================================================
  // 💬 COMUNICAÇÃO
  // =============================================================================
  
  static PhosphorIconData get comment => PhosphorIcons.chatCircle(PhosphorIconsStyle.regular);
  static PhosphorIconData get commentFill => PhosphorIcons.chatCircle(PhosphorIconsStyle.fill);
  static PhosphorIconData get notification => PhosphorIcons.bell(PhosphorIconsStyle.regular);
  static PhosphorIconData get notificationFill => PhosphorIcons.bell(PhosphorIconsStyle.fill);
  static PhosphorIconData get mail => PhosphorIcons.envelope(PhosphorIconsStyle.regular);
  static PhosphorIconData get mailFill => PhosphorIcons.envelope(PhosphorIconsStyle.fill);
  static PhosphorIconData get phone => PhosphorIcons.phone(PhosphorIconsStyle.regular);
  static PhosphorIconData get chat => PhosphorIcons.chatTeardrop(PhosphorIconsStyle.regular);

  // =============================================================================
  // 👤 USUÁRIO E PERFIL
  // =============================================================================
  
  static PhosphorIconData get user => PhosphorIcons.user(PhosphorIconsStyle.regular);
  static PhosphorIconData get userFill => PhosphorIcons.user(PhosphorIconsStyle.fill);
  static PhosphorIconData get users => PhosphorIcons.users(PhosphorIconsStyle.regular);
  static PhosphorIconData get usersFill => PhosphorIcons.users(PhosphorIconsStyle.fill);
  static PhosphorIconData get userCircle => PhosphorIcons.userCircle(PhosphorIconsStyle.regular);
  static PhosphorIconData get userCircleFill => PhosphorIcons.userCircle(PhosphorIconsStyle.fill);

  // =============================================================================
  // ⚙️ CONFIGURAÇÕES E AÇÕES
  // =============================================================================
  
  static PhosphorIconData get settings => PhosphorIcons.gear(PhosphorIconsStyle.regular);
  static PhosphorIconData get settingsFill => PhosphorIcons.gear(PhosphorIconsStyle.fill);
  static PhosphorIconData get edit => PhosphorIcons.pencil(PhosphorIconsStyle.regular);
  static PhosphorIconData get editFill => PhosphorIcons.pencil(PhosphorIconsStyle.fill);
  static PhosphorIconData get delete => PhosphorIcons.trash(PhosphorIconsStyle.regular);
  static PhosphorIconData get deleteFill => PhosphorIcons.trash(PhosphorIconsStyle.fill);
  static PhosphorIconData get plus => PhosphorIcons.plus(PhosphorIconsStyle.regular);
  static PhosphorIconData get minus => PhosphorIcons.minus(PhosphorIconsStyle.regular);
  static PhosphorIconData get signOut => PhosphorIcons.signOut(PhosphorIconsStyle.regular);
  static PhosphorIconData get copy => PhosphorIcons.copy(PhosphorIconsStyle.regular);
  static PhosphorIconData get download => PhosphorIcons.download(PhosphorIconsStyle.regular);
  static PhosphorIconData get upload => PhosphorIcons.upload(PhosphorIconsStyle.regular);

  // =============================================================================
  // 🕐 TEMPO E DATA
  // =============================================================================
  
  static PhosphorIconData get calendar => PhosphorIcons.calendar(PhosphorIconsStyle.regular);
  static PhosphorIconData get calendarFill => PhosphorIcons.calendar(PhosphorIconsStyle.fill);
  static PhosphorIconData get clock => PhosphorIcons.clock(PhosphorIconsStyle.regular);
  static PhosphorIconData get clockFill => PhosphorIcons.clock(PhosphorIconsStyle.fill);
  static PhosphorIconData get timer => PhosphorIcons.timer(PhosphorIconsStyle.regular);
  static PhosphorIconData get history => PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular);

  // =============================================================================
  // 📷 MÍDIA E CONTEÚDO
  // =============================================================================
  
  static PhosphorIconData get camera => PhosphorIcons.camera(PhosphorIconsStyle.regular);
  static PhosphorIconData get cameraFill => PhosphorIcons.camera(PhosphorIconsStyle.fill);
  static PhosphorIconData get image => PhosphorIcons.image(PhosphorIconsStyle.regular);
  static PhosphorIconData get imageFill => PhosphorIcons.image(PhosphorIconsStyle.fill);
  static PhosphorIconData get images => PhosphorIcons.images(PhosphorIconsStyle.regular);
  static PhosphorIconData get video => PhosphorIcons.videoCamera(PhosphorIconsStyle.regular);
  static PhosphorIconData get play => PhosphorIcons.play(PhosphorIconsStyle.regular);
  static PhosphorIconData get playFill => PhosphorIcons.play(PhosphorIconsStyle.fill);
  static PhosphorIconData get pause => PhosphorIcons.pause(PhosphorIconsStyle.regular);
  static PhosphorIconData get stop => PhosphorIcons.stop(PhosphorIconsStyle.regular);

  // =============================================================================
  // 🔒 SEGURANÇA E PRIVACIDADE
  // =============================================================================
  
  static PhosphorIconData get eye => PhosphorIcons.eye(PhosphorIconsStyle.regular);
  static PhosphorIconData get eyeFill => PhosphorIcons.eye(PhosphorIconsStyle.fill);
  static PhosphorIconData get eyeSlash => PhosphorIcons.eyeSlash(PhosphorIconsStyle.regular);
  static PhosphorIconData get eyeSlashFill => PhosphorIcons.eyeSlash(PhosphorIconsStyle.fill);
  static PhosphorIconData get lock => PhosphorIcons.lock(PhosphorIconsStyle.regular);
  static PhosphorIconData get lockFill => PhosphorIcons.lock(PhosphorIconsStyle.fill);
  static PhosphorIconData get lockOpen => PhosphorIcons.lockOpen(PhosphorIconsStyle.regular);
  static PhosphorIconData get key => PhosphorIcons.key(PhosphorIconsStyle.regular);

  // =============================================================================
  // ✅ STATUS E FEEDBACK
  // =============================================================================
  
  static PhosphorIconData get check => PhosphorIcons.check(PhosphorIconsStyle.regular);
  static PhosphorIconData get checkCircle => PhosphorIcons.checkCircle(PhosphorIconsStyle.regular);
  static PhosphorIconData get checkCircleFill => PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
  static PhosphorIconData get warning => PhosphorIcons.warning(PhosphorIconsStyle.regular);
  static PhosphorIconData get warningFill => PhosphorIcons.warning(PhosphorIconsStyle.fill);
  static PhosphorIconData get info => PhosphorIcons.info(PhosphorIconsStyle.regular);
  static PhosphorIconData get infoFill => PhosphorIcons.info(PhosphorIconsStyle.fill);
  static PhosphorIconData get error => PhosphorIcons.xCircle(PhosphorIconsStyle.regular);
  static PhosphorIconData get errorFill => PhosphorIcons.xCircle(PhosphorIconsStyle.fill);
  static PhosphorIconData get success => PhosphorIcons.checkCircle(PhosphorIconsStyle.regular);
  static PhosphorIconData get successFill => PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);

  // =============================================================================
  // 🏷️ PROMOÇÕES E COMÉRCIO
  // =============================================================================
  
  static PhosphorIconData get tag => PhosphorIcons.tag(PhosphorIconsStyle.regular);
  static PhosphorIconData get tagFill => PhosphorIcons.tag(PhosphorIconsStyle.fill);
  static PhosphorIconData get gift => PhosphorIcons.gift(PhosphorIconsStyle.regular);
  static PhosphorIconData get giftFill => PhosphorIcons.gift(PhosphorIconsStyle.fill);
  static PhosphorIconData get percent => PhosphorIcons.percent(PhosphorIconsStyle.regular);
  static PhosphorIconData get receipt => PhosphorIcons.receipt(PhosphorIconsStyle.regular);
  static PhosphorIconData get creditCard => PhosphorIcons.creditCard(PhosphorIconsStyle.regular);
  static PhosphorIconData get money => PhosphorIcons.currencyDollar(PhosphorIconsStyle.regular);
  static PhosphorIconData get shoppingCart => PhosphorIcons.shoppingCart(PhosphorIconsStyle.regular);

  // =============================================================================
  // 🎯 ESPECÍFICOS KAFEX
  // =============================================================================
  
  static PhosphorIconData get listChecks => PhosphorIcons.listChecks(PhosphorIconsStyle.regular);
  static PhosphorIconData get trendUp => PhosphorIcons.trendUp(PhosphorIconsStyle.regular);
  static PhosphorIconData get trendDown => PhosphorIcons.trendDown(PhosphorIconsStyle.regular);
  static PhosphorIconData get fire => PhosphorIcons.fire(PhosphorIconsStyle.regular);
  static PhosphorIconData get fireFill => PhosphorIcons.fire(PhosphorIconsStyle.fill);
  
  // =============================================================================
  // 📱 INTERFACE E DISPOSITIVOS
  // =============================================================================
  
  static PhosphorIconData get desktop => PhosphorIcons.desktop(PhosphorIconsStyle.regular);
  static PhosphorIconData get device => PhosphorIcons.deviceMobile(PhosphorIconsStyle.regular);
  static PhosphorIconData get wifiHigh => PhosphorIcons.wifiHigh(PhosphorIconsStyle.regular);
  static PhosphorIconData get wifiSlash => PhosphorIcons.wifiSlash(PhosphorIconsStyle.regular);
  
  // =============================================================================
  // 🌐 CONECTIVIDADE E WEB
  // =============================================================================
  
  static PhosphorIconData get globe => PhosphorIcons.globe(PhosphorIconsStyle.regular);
  static PhosphorIconData get globeFill => PhosphorIcons.globe(PhosphorIconsStyle.fill);
  static PhosphorIconData get link => PhosphorIcons.link(PhosphorIconsStyle.regular);
  static PhosphorIconData get linkBreak => PhosphorIcons.linkBreak(PhosphorIconsStyle.regular);
  static PhosphorIconData get qrCode => PhosphorIcons.qrCode(PhosphorIconsStyle.regular);

  // =============================================================================
  // 📊 DADOS E ANÁLISE
  // =============================================================================
  
  static PhosphorIconData get chartLine => PhosphorIcons.chartLine(PhosphorIconsStyle.regular);
  static PhosphorIconData get chartBar => PhosphorIcons.chartBar(PhosphorIconsStyle.regular);
  static PhosphorIconData get chartPie => PhosphorIcons.chartPie(PhosphorIconsStyle.regular);

  // =============================================================================
  // 🎨 PERSONALIZAÇÃO
  // =============================================================================
  
  static PhosphorIconData get palette => PhosphorIcons.palette(PhosphorIconsStyle.regular);
  static PhosphorIconData get paintBrush => PhosphorIcons.paintBrush(PhosphorIconsStyle.regular);
  static PhosphorIconData get eyedropper => PhosphorIcons.eyedropper(PhosphorIconsStyle.regular);
  static PhosphorIconData get textAa => PhosphorIcons.textAa(PhosphorIconsStyle.regular);

  // =============================================================================
  // 🚀 MÉTODOS DE CONVENIÊNCIA
  // =============================================================================
  
  /// Retorna um ícone de status baseado em uma condição booleana
  static PhosphorIconData getToggleIcon({
    required bool isActive,
    required PhosphorIconData activeIcon,
    required PhosphorIconData inactiveIcon,
  }) {
    return isActive ? activeIcon : inactiveIcon;
  }
  
  /// Retorna ícone de rating baseado no índice e valor
  static PhosphorIconData getRatingIcon(int index, double rating) {
    return index < rating.floor() ? starFill : star;
  }
}