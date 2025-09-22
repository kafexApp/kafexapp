import 'package:phosphor_flutter/phosphor_flutter.dart';

// Classe centralizada com todos os ícones do Kafex usando Phosphor
class AppIcons {
  // ===== NAVEGAÇÃO =====
  static PhosphorIconData get home => PhosphorIcons.house();
  static PhosphorIconData get homeFill => PhosphorIcons.house(PhosphorIconsStyle.fill);
  static PhosphorIconData get back => PhosphorIcons.arrowLeft();
  static PhosphorIconData get forward => PhosphorIcons.arrowRight();
  static PhosphorIconData get close => PhosphorIcons.x();
  static PhosphorIconData get menu => PhosphorIcons.list();

  // ===== CAFÉ & COMIDA =====
  static PhosphorIconData get coffee => PhosphorIcons.coffee();
  static PhosphorIconData get coffeeFill => PhosphorIcons.coffee(PhosphorIconsStyle.fill);
  static PhosphorIconData get coffeeCup => PhosphorIcons.coffeeCup();
  static PhosphorIconData get wineCup => PhosphorIcons.wine(); // Para café especial

  // ===== LOCALIZAÇÃO =====
  static PhosphorIconData get location => PhosphorIcons.mapPin();
  static PhosphorIconData get locationFill => PhosphorIcons.mapPin(PhosphorIconsStyle.fill);
  static PhosphorIconData get map => PhosphorIcons.map();
  static PhosphorIconData get compass => PhosphorIcons.compass();
  static PhosphorIconData get navigation => PhosphorIcons.navigation();

  // ===== BUSCA & FILTROS =====
  static PhosphorIconData get search => PhosphorIcons.magnifyingGlass();
  static PhosphorIconData get filter => PhosphorIcons.funnel();
  static PhosphorIconData get filterFill => PhosphorIcons.funnel(PhosphorIconsStyle.fill);
  static PhosphorIconData get sliders => PhosphorIcons.sliders();

  // ===== INTERAÇÕES =====
  static PhosphorIconData get heart => PhosphorIcons.heart();
  static PhosphorIconData get heartFill => PhosphorIcons.heart(PhosphorIconsStyle.fill);
  static PhosphorIconData get star => PhosphorIcons.star();
  static PhosphorIconData get starFill => PhosphorIcons.star(PhosphorIconsStyle.fill);
  static PhosphorIconData get thumbsUp => PhosphorIcons.thumbsUp();
  static PhosphorIconData get thumbsUpFill => PhosphorIcons.thumbsUp(PhosphorIconsStyle.fill);
  static PhosphorIconData get share => PhosphorIcons.shareNetwork();

  // ===== COMUNICAÇÃO =====
  static PhosphorIconData get comment => PhosphorIcons.chatCircle();
  static PhosphorIconData get commentFill => PhosphorIcons.chatCircle(PhosphorIconsStyle.fill);
  static PhosphorIconData get notification => PhosphorIcons.bell();
  static PhosphorIconData get notificationFill => PhosphorIcons.bell(PhosphorIconsStyle.fill);
  static PhosphorIconData get mail => PhosphorIcons.envelope();
  static PhosphorIconData get phone => PhosphorIcons.phone();

  // ===== USUÁRIO =====
  static PhosphorIconData get user => PhosphorIcons.user();
  static PhosphorIconData get userFill => PhosphorIcons.user(PhosphorIconsStyle.fill);
  static PhosphorIconData get users => PhosphorIcons.users();
  static PhosphorIconData get userProfile => PhosphorIcons.userCircle();

  // ===== CONFIGURAÇÕES =====
  static PhosphorIconData get settings => PhosphorIcons.gear();
  static PhosphorIconData get settingsFill => PhosphorIcons.gear(PhosphorIconsStyle.fill);
  static PhosphorIconData get edit => PhosphorIcons.pencil();
  static PhosphorIconData get delete => PhosphorIcons.trash();
  static PhosphorIconData get plus => PhosphorIcons.plus();
  static PhosphorIconData get minus => PhosphorIcons.minus();

  // ===== TEMPO & DATA =====
  static PhosphorIconData get calendar => PhosphorIcons.calendar();
  static PhosphorIconData get calendarFill => PhosphorIcons.calendar(PhosphorIconsStyle.fill);
  static PhosphorIconData get clock => PhosphorIcons.clock();
  static PhosphorIconData get clockFill => PhosphorIcons.clock(PhosphorIconsStyle.fill);

  // ===== MÍDIA =====
  static PhosphorIconData get camera => PhosphorIcons.camera();
  static PhosphorIconData get cameraFill => PhosphorIcons.camera(PhosphorIconsStyle.fill);
  static PhosphorIconData get image => PhosphorIcons.image();
  static PhosphorIconData get play => PhosphorIcons.play();
  static PhosphorIconData get playFill => PhosphorIcons.play(PhosphorIconsStyle.fill);

  // ===== SENHA & SEGURANÇA =====
  static PhosphorIconData get eye => PhosphorIcons.eye();
  static PhosphorIconData get eyeSlash => PhosphorIcons.eyeSlash();
  static PhosphorIconData get lock => PhosphorIcons.lock();
  static PhosphorIconData get lockOpen => PhosphorIcons.lockOpen();

  // ===== STATUS & FEEDBACK =====
  static PhosphorIconData get check => PhosphorIcons.check();
  static PhosphorIconData get checkCircle => PhosphorIcons.checkCircle();
  static PhosphorIconData get checkCircleFill => PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
  static PhosphorIconData get warning => PhosphorIcons.warning();
  static PhosphorIconData get warningFill => PhosphorIcons.warning(PhosphorIconsStyle.fill);
  static PhosphorIconData get info => PhosphorIcons.info();
  static PhosphorIconData get infoFill => PhosphorIcons.info(PhosphorIconsStyle.fill);

  // ===== PROMOÇÕES & OFERTAS =====
  static PhosphorIconData get tag => PhosphorIcons.tag();
  static PhosphorIconData get tagFill => PhosphorIcons.tag(PhosphorIconsStyle.fill);
  static PhosphorIconData get gift => PhosphorIcons.gift();
  static PhosphorIconData get giftFill => PhosphorIcons.gift(PhosphorIconsStyle.fill);
  static PhosphorIconData get percent => PhosphorIcons.percent();

  // ===== ESPECÍFICOS KAFEX =====
  static PhosphorIconData get storefront => PhosphorIcons.storefront(); // Para cafeterias
  static PhosphorIconData get storefrontFill => PhosphorIcons.storefront(PhosphorIconsStyle.fill);
  static PhosphorIconData get bookmark => PhosphorIcons.bookmark(); // Para favoritos
  static PhosphorIconData get bookmarkFill => PhosphorIcons.bookmark(PhosphorIconsStyle.fill);
  static PhosphorIconData get listCheck => PhosphorIcons.listChecks(); // Para reviews
  static PhosphorIconData get trendUp => PhosphorIcons.trendUp(); // Para cafés em alta
}