import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';
import 'package:vos_flutter/feature/news_detail/domain/models/news_detail_args.dart';
import 'package:vos_flutter/feature/news_detail/domain/usecases/get_news_usecase.dart';
import 'package:vos_flutter/feature/news_detail/domain/usecases/get_article_detail_usecase.dart';
import 'package:vos_flutter/feature/news_detail/domain/usecases/search_news_usecase.dart';
import 'package:vos_flutter/feature/news_detail/domain/usecases/create_article_usecase.dart';
import 'package:vos_flutter/feature/news_detail/domain/usecases/update_article_usecase.dart';
import 'package:vos_flutter/feature/news_detail/domain/usecases/delete_article_usecase.dart';

class NewsDetailController extends BaseController with ApiResultMixin {
  final NewsDetailArgs? args;

  // Extract fields nếu cần (optional, để code ngắn gọn hơn)
  String? get id => args?.id;
  String? get url => args?.url;
  String? get title => args?.title;

  final GetNewsDetailUsecase getNewsUsecase;

  final GetNewsDetailArticleUsecase getArticleDetailUsecase;

  final SearchNewsDetailUsecase searchNewsUsecase;

  final CreateNewsDetailArticleUsecase createArticleUsecase;

  final UpdateNewsDetailArticleUsecase updateArticleUsecase;

  final DeleteNewsDetailArticleUsecase deleteArticleUsecase;

  final RxList<NewsDetail> newsDetails = <NewsDetail>[].obs;

  final Rxn<NewsDetail> selectedNewsDetail = Rxn<NewsDetail>();

  ProfileController? _cachedProfileController;

  ProfileController? get _profileController {
    if (_cachedProfileController != null) {
      return _cachedProfileController;
    }
    if (!Get.isRegistered<ProfileController>()) {
      print('⚠️ ProfileController chưa được register');
      return null;
    }
    try {
      _cachedProfileController = Get.find<ProfileController>();
      print('✅ ProfileController found: ${_cachedProfileController != null}');
      if (_cachedProfileController != null) {
        print(
          '✅ userProfile.value: ${_cachedProfileController!.userProfile.value != null}',
        );
        final token = _cachedProfileController!.userProfile.value?.token;
        if (token != null && token.isNotEmpty) {
          final preview = token.length > 20 ? token.substring(0, 20) : token;
          print('✅ token: $preview...');
        } else {
          print('✅ token: null');
        }
      }
    } catch (e) {
      print('❌ Error finding ProfileController: $e');
      return null;
    }
    return _cachedProfileController;
  }

  String? get vacsToken {
    // Ưu tiên lấy từ ProfileController
    final profileToken = _profileController?.userProfile.value?.token;
    if (profileToken != null && profileToken.isNotEmpty) {
      print(
        '🔑 vacsToken từ ProfileController: ${profileToken.substring(0, profileToken.length > 20 ? 20 : profileToken.length)}...',
      );
      return profileToken;
    }

    // Fallback: lấy trực tiếp từ storage
    try {
      final storage = GetStorage();
      final userProfileData = storage.read('user_profile_data');
      if (userProfileData != null && userProfileData is Map) {
        final token = userProfileData['Token'] as String?;
        if (token != null && token.isNotEmpty) {
          print(
            '🔑 vacsToken từ storage: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
          );
          return token;
        }
      }
    } catch (e) {
      print('❌ Error reading token from storage: $e');
    }

    print('⚠️ vacsToken: null (không tìm thấy token)');
    return null;
  }

  void setSelectedNewsDetail(NewsDetail? value) {
    selectedNewsDetail.value = value;
  }

  final RxString searchQuery = ''.obs;

  NewsDetailController({
    this.args,
    required this.getNewsUsecase,
    required this.getArticleDetailUsecase,
    required this.searchNewsUsecase,
    required this.createArticleUsecase,
    required this.updateArticleUsecase,
    required this.deleteArticleUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    // Sử dụng args trực tiếp
    if (args?.isAppType == true && id != null && id!.isNotEmpty) {
      getArticleDetail(id!);
    } else {
      getNews();
    }
  }

  void _replaceList(List<NewsDetail> data, {bool append = false}) {
    if (append) {
      newsDetails.addAll(data);
    } else {
      newsDetails.assignAll(data);
    }
  }

  Future<void> onRefresh() async {
    await getNews();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  Future<void> onSearch(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      await getNews();

      return;
    }

    await searchNews(query);
  }

  Future<void> getNews() async {
    await handleApiCall<List<NewsDetail>>(
      apiCall: () => getNewsUsecase.call(),
      onSuccess: (data) {
        _replaceList(data);
      },
    );
  }

  Future<void> getArticleDetail(String id) async {
    await handleApiCall<NewsDetail>(
      apiCall: () => getArticleDetailUsecase.call(id),
      onSuccess: (data) {
        selectedNewsDetail.value = data;
      },
    );
  }

  Future<void> searchNews(String query) async {
    await handleApiCall<List<NewsDetail>>(
      apiCall: () => searchNewsUsecase.call(query),
      onSuccess: (data) {
        _replaceList(data);
      },
    );
  }

  Future<void> createArticle(NewsDetail item) async {
    final success = await handleApiCallVoid(
      apiCall: () => createArticleUsecase.call(item),
    );
    if (success) {
      await getNews();
    }
  }

  Future<void> updateArticle(NewsDetail item) async {
    await handleApiCall<bool>(
      apiCall: () => updateArticleUsecase.call(item),
      onSuccess: (data) {
        final updatedItem = item;
        final listRef = newsDetails;
        final index = listRef.indexWhere(
          (element) => element.id == updatedItem.id,
        );
        if (index != -1) {
          listRef[index] = updatedItem;
          listRef.refresh();
        }
      },
    );
  }

  Future<void> deleteArticle(String id) async {
    await handleApiCall<bool>(
      apiCall: () => deleteArticleUsecase.call(id),
      onSuccess: (data) {
        if (data) {
          newsDetails.removeWhere((element) => element.id == id);
        }
      },
    );
  }
}
