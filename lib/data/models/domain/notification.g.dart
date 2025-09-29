// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  id: json['id'] as String,
  type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
  title: json['title'] as String,
  message: json['message'] as String,
  time: DateTime.parse(json['time'] as String),
  isRead: json['isRead'] as bool? ?? false,
  icon: json['icon'] as String?,
  actionUrl: json['actionUrl'] as String?,
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$NotificationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'message': instance.message,
  'time': instance.time.toIso8601String(),
  'isRead': instance.isRead,
  'icon': instance.icon,
  'actionUrl': instance.actionUrl,
};

const _$NotificationTypeEnumMap = {
  NotificationType.newPlace: 'newPlace',
  NotificationType.promotion: 'promotion',
  NotificationType.review: 'review',
  NotificationType.appUpdate: 'appUpdate',
  NotificationType.community: 'community',
};
