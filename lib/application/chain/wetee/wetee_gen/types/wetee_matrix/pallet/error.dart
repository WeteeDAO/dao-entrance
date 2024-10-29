// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

/// The `Error` enum of this pallet.
enum Error {
  /// Do not have permission to create.
  /// 没有创建的权限
  haveNoCreatePermission('HaveNoCreatePermission', 0),

  /// Node already exists
  /// 节点已存在
  nodeExists('NodeExists', 1),

  /// Node does not exist.
  /// 节点不存在
  nodeNotExists('NodeNotExists', 2),

  /// guild create error
  /// 公会创建失败
  guildCreateError('GuildCreateError', 3),

  /// guild does not exist.
  /// 公会不存在
  guildNotExists('GuildNotExists', 4),

  /// Node unsupported call
  /// 无效的调用
  inVailCall('InVailCall', 5),

  /// Node unsupported pallet
  /// 无效的Pallet
  inVailPallet('InVailPallet', 6),

  /// Wrong origin.
  /// 错误的节点
  badOrigin('BadOrigin', 7),

  /// Not the id of this node.
  /// 节点 id 不正确
  nodeIdNotMatch('NodeIdNotMatch', 8),

  /// The description of the Node is too long.
  /// 名字太长
  nameTooLong('NameTooLong', 9),

  /// The description of the Node is too long.
  /// 节点介绍太长
  descTooLong('DescTooLong', 10),

  /// The description of the Node is too long.
  /// 节点目标太长
  purposeTooLong('PurposeTooLong', 11),

  /// The description of the Node is too long.
  /// 节点目标太长
  metaDataTooLong('MetaDataTooLong', 12),

  /// Numerical calculation overflow error.
  /// 溢出错误
  overflow('Overflow', 13);

  const Error(
    this.variantName,
    this.codecIndex,
  );

  factory Error.decode(_i1.Input input) {
    return codec.decode(input);
  }

  final String variantName;

  final int codecIndex;

  static const $ErrorCodec codec = $ErrorCodec();

  String toJson() => variantName;
  _i2.Uint8List encode() {
    return codec.encode(this);
  }
}

class $ErrorCodec with _i1.Codec<Error> {
  const $ErrorCodec();

  @override
  Error decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return Error.haveNoCreatePermission;
      case 1:
        return Error.nodeExists;
      case 2:
        return Error.nodeNotExists;
      case 3:
        return Error.guildCreateError;
      case 4:
        return Error.guildNotExists;
      case 5:
        return Error.inVailCall;
      case 6:
        return Error.inVailPallet;
      case 7:
        return Error.badOrigin;
      case 8:
        return Error.nodeIdNotMatch;
      case 9:
        return Error.nameTooLong;
      case 10:
        return Error.descTooLong;
      case 11:
        return Error.purposeTooLong;
      case 12:
        return Error.metaDataTooLong;
      case 13:
        return Error.overflow;
      default:
        throw Exception('Error: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(
    Error value,
    _i1.Output output,
  ) {
    _i1.U8Codec.codec.encodeTo(
      value.codecIndex,
      output,
    );
  }
}
