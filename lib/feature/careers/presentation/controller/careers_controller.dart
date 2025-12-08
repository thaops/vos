import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
import 'package:vos_flutter/common/mixins/pagination_mixin.dart';
import 'package:vos_flutter/feature/news/domain/models/news.dart';
import 'package:vos_flutter/feature/news/domain/usecases/get_news_usecase.dart';
import 'package:vos_flutter/feature/news/domain/usecases/get_article_detail_usecase.dart';
import 'package:vos_flutter/feature/news/domain/usecases/search_news_usecase.dart';

class CareersController extends BaseController
    with ApiResultMixin, PaginationMixin<News> {
  final GetNewsUsecase getNewsUsecase;
  final GetArticleDetailUsecase getArticleDetailUsecase;
  final SearchNewsUsecase searchNewsUsecase;

  RxList<News> get careers => items;
  final int pageSize = 10;

  final Rxn<News> selectedNews = Rxn<News>();

  void setSelectedNews(News? value) {
    selectedNews.value = value;
  }

  final RxString searchQuery = ''.obs;

  CareersController({
    required this.getNewsUsecase,
    required this.getArticleDetailUsecase,
    required this.searchNewsUsecase,
  });

  @override
  void onInit() {
    super.onInit();
    fetchPage(1);
  }

  void _replaceList(List<News> data, {bool append = false}) {
    // Filter chỉ lấy news có CategoryCode == "Careers"
    final filteredData = data
        .where((news) => news.categoryCode == 'Careers')
        .toList();

    if (append) {
      appendPage(filteredData);
    } else {
      items.assignAll(filteredData);
    }
  }

  @override
  Future<void> fetchPage(int page) async {
    await getCareers(page: page, limit: pageSize, keyword: searchQuery.value);
  }

  Future<void> onRefresh() async {
    resetPagination();
    await fetchPage(1);
  }

  Future<void> onLoadMore() async {
    await loadNextPage();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  Future<void> onSearch(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      await onRefresh();
      return;
    }

    resetPagination();
    await getCareers(page: 1, limit: pageSize, keyword: query);
  }

  Future<void> getCareers({
    int page = 1,
    int limit = 10,
    String keyword = '',
  }) async {
    await handleApiCall<List<News>>(
      apiCall: () =>
          getNewsUsecase.call(page: page, limit: limit, keyword: keyword),
      onSuccess: (data) {
        if (page == 1) {
          _replaceList(data);
        } else {
          _replaceList(data, append: true);
        }
      },
    );
  }

  Future<void> getArticleDetail(String id) async {
    await handleApiCall<News>(
      apiCall: () => getArticleDetailUsecase.call(id),
      onSuccess: (data) {
        selectedNews.value = data;
      },
    );
  }
}

