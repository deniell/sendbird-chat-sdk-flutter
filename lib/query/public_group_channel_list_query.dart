import 'package:json_annotation/json_annotation.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/models/error.dart';
import 'package:sendbird_sdk/core/models/group_channel_filters.dart';
import 'package:sendbird_sdk/query/base_query.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';

part 'public_group_channel_list_query.g.dart';

/// A query object to retrieve list of public group channel.
@JsonSerializable()
class PublicGroupChannelListQuery extends QueryBase {
  /// Filters for channel urls.
  ///
  /// Result will return a list containing only and exactly matched
  /// with given urls. This filter does not cooperate with other filters.
  List<String> channelUrls;

  /// Filters channels for super group channel. Default is `all`
  SuperChannelFilter superChannelFilter;

  /// Filters by current user's member state in public group channel
  PublicGroupChannelMembershipFilter membershipFilter;

  /// Order of query result
  PublicGroupChannelListOrder order;

  /// Filter by custom type that starts with
  String customTypeStartWithFilter;

  /// Filters by custom types.
  List<String> customTypesFilter;

  /// Filters by channel name contains certain text
  String channelNameContainsFilter;

  /// Sets metadata's key for ordering its value
  ///
  /// This is valid when the `order` is `channelMetaDataValueAlphabetical` only
  String metaDataOrderKeyFilter;

  /// Query result includes empty (message) channel if `true`
  /// default value is `true`
  bool includeEmptyChannel = true;

  /// Query result includes frozen channels if `true`
  /// default value is `true`
  bool includeFrozenChannel = true;

  /// Query result of channel object contains member list if `true`
  /// default value is `true`
  bool includeMemberList = true;

  /// Query result of channel object contains meta data if `true`
  /// deault value is `true`
  bool includeMetaData = true;

  PublicGroupChannelListQuery();

  @override
  Future<List<GroupChannel>> loadNext() async {
    if (loading) throw QueryInProgressError();
    if (!hasNext) return [];

    loading = true;

    List<ChannelQueryIncludeOption> options = [
      if (includeFrozenChannel) ChannelQueryIncludeOption.frozenChannel,
      if (includeEmptyChannel) ChannelQueryIncludeOption.emptyChannel,
      if (includeMemberList) ChannelQueryIncludeOption.memberList,
      if (includeMetaData) ChannelQueryIncludeOption.metaData,
      ChannelQueryIncludeOption.readReceipt,
      ChannelQueryIncludeOption.deliveryReceipt,
    ];

    final filter = GroupChannelFilter()
      ..customTypeStartswith = customTypeStartWithFilter
      ..customTypes = customTypesFilter
      ..nameContains = channelNameContainsFilter
      ..superMode = superChannelFilter
      ..publicMembershipFilter = membershipFilter
      ..metadataOrderKey = metaDataOrderKeyFilter
      ..publicMode = PublicChannelFilter.public;

    final sdk = SendbirdSdk().getInternal();
    final res = await sdk.api.getPublicGroupChannels(
      order: order,
      token: token,
      limit: limit,
      channelUrls: channelUrls,
      options: options,
      filter: filter,
    );

    loading = false;
    token = res.next;
    hasNext = res.next != '';
    return res.channels;
  }

  // Json Serialization

  Map<String, dynamic> toJson() => _$PublicGroupChannelListQueryToJson(this);
}
