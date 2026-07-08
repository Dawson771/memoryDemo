// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PluginModel _$PluginModelFromJson(Map<String, dynamic> json) => PluginModel(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      widget: json['widget'] as Map<String, dynamic>,
      actions: (json['actions'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, PluginAction.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$PluginModelToJson(PluginModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'icon': instance.icon,
      'widget': instance.widget,
      'actions': instance.actions,
    };

PluginAction _$PluginActionFromJson(Map<String, dynamic> json) => PluginAction(
      type: $enumDecode(_$PluginActionTypeEnumMap, json['type']),
      route: json['route'] as String?,
      method: json['method'] as String?,
      params: json['params'] as Map<String, dynamic>?,
      dialogTitle: json['dialogTitle'] as String?,
      dialogContent: json['dialogContent'] as String?,
    );

Map<String, dynamic> _$PluginActionToJson(PluginAction instance) =>
    <String, dynamic>{
      'type': _$PluginActionTypeEnumMap[instance.type]!,
      'route': instance.route,
      'method': instance.method,
      'params': instance.params,
      'dialogTitle': instance.dialogTitle,
      'dialogContent': instance.dialogContent,
    };

const _$PluginActionTypeEnumMap = {
  PluginActionType.navigate: 'navigate',
  PluginActionType.method: 'method',
  PluginActionType.dialog: 'dialog',
};
