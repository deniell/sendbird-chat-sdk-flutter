import 'package:json_annotation/json_annotation.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/channel/group/group_channel.dart';
import 'package:sendbird_sdk/core/models/error.dart';
import 'package:sendbird_sdk/core/models/group_channel_filters.dart';
import 'package:sendbird_sdk/query/base_query.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';

part 'group_channel_list_query.g.dart';

/// A query object to retrieve list of my group channel.
@JsonSerializable()
class GroupChannelListQuery extends QueryBase {
  /// Order of the query result
  GroupChannelListOrder order;

  /// Sets query type user Id filter, it only will work when `includeMemberList` is true
  GroupChannelListQueryType queryType;

  /// Sets filter channel urls.
  ///
  /// It will return a list containing only and exactly matched
  /// with given urls. This filter does not cooperate with other filters.
  List<String> channelUrls;

  /// Sets the member state filter
  MemberStateFilter memberStateFilter;

  /// Sets to filter super channel. Default is `all`
  SuperChannelFilter superChannelFilter;

  /// Sets to filter public channel. Default is `all`
  PublicChannelFilter publicChannelFilter;

  /// Sets to filter channels by custom type that starts with
  String customTypeStartWithFilter;

  /// Sets the custom type filter.
  List<String> customTypesFilter;

  /// Sets the filter with nickname.
  ///
  /// Query result will contains
  /// channels that any one of member contains given nickname
  String nicknameContainsFilter;

  /// Sets the filter with user IDs
  ///
  /// Query result will return if any one of user id matches with channel's members
  List<String> userIdsIncludeFilter;

  /// Sets the filter with user IDs
  ///
  /// Query result will return only if channel's members are exactly matched
  /// with this property
  List<String> userIdsExactFilter;

  /// Sets a filter to return only channels that contains the
  /// specified group channel name
  String channelNameContainsFilter;

  /// Sets to filter channels by the unread messages.
  /// The default value is `all`
  UnreadChannelFilter unreadChannelFilter;

  /// Sets a key for ordering by value in the metadata.
  /// This is valid when the `order` is `channelMetaDataValueAlphabetical` only
  String metaDataOrderKeyFilter;

  /// Sets to filter channels by the hidden state.
  /// The default value is `unhiddenOnly`
  ChannelHiddenStateFilter channelHiddenStateFilter;

  String searchQuery;
  List<GroupChannelListQuerySearchField> searchFields;

  /// Query result includes empty (message) channel if `true`.
  /// default value is `true`
  bool includeEmptyChannel = true;

  /// Query result includes frozen channels if `true`.
  /// default value is `true`
  bool includeFrozenChannel = true;

  /// Query result of channel object contains member list if `true`.
  /// default value is `true`
  bool includeMemberList = true;

  // Query result of channel object contains meta data if `true`.
  // deault value is `false`
  bool includeMetaData = true;

  GroupChannelListQuery();

  void setUserIdsExactFilter(List<String> userIds) {
    nicknameContainsFilter = null;
    userIdsIncludeFilter = null;
    userIdsExactFilter = userIds;
  }

  void setUserIdsIncludeFilter(
      List<String> userIds, GroupChannelListQueryType type) {
    nicknameContainsFilter = null;
    userIdsExactFilter = null;
    userIdsIncludeFilter = userIds;
    queryType = type;
  }

  void setNicknameContainsFilter(String nickname) {
    userIdsIncludeFilter = null;
    userIdsExactFilter = null;
    nicknameContainsFilter = nickname;
  }

  void setSearchFilter(
      String searchQuery, List<GroupChannelListQuerySearchField> searchFields) {
    searchQuery = searchQuery;
    searchFields = searchFields;
  }

  void setChannelUrlsFilter(List<String> channelUrls) {
    userIdsExactFilter = null;
    userIdsIncludeFilter = null;
    searchFields = null;
    searchQuery = null;
    nicknameContainsFilter = null;
    channelUrls = channelUrls;
  }

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
      ..memberStateFilter = memberStateFilter
      ..membersExactlyIn = userIdsExactFilter
      ..membersIncludeIn = userIdsIncludeFilter
      ..membersNicknameContains = nicknameContainsFilter
      ..nameContains = channelNameContainsFilter
      ..superMode = superChannelFilter
      ..publicMode = publicChannelFilter
      ..unreadFilter = unreadChannelFilter
      ..metadataOrderKey = metaDataOrderKeyFilter
      ..hiddenMode = channelHiddenStateFilter;

    final sdk = SendbirdSdk().getInternal();
    final res = await sdk.api.getMyGroupChannels(
      userId: sdk.state.currentUser.userId,
      order: order,
      queryType: queryType,
      token: token,
      limit: limit,
      channelUrls: channelUrls,
      options: options,
      filter: filter,
      searchQuery: searchQuery,
      searchFields: searchFields,
    );

    loading = false;
    token = res.next;
    hasNext = res.next != '';
    return res.channels;
  }

  // Json Serialization

  Map<String, dynamic> toJson() => _$GroupChannelListQueryToJson(this);
}
