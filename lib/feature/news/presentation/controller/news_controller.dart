import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';

import 'package:vos_flutter/common/mixins/pagination_mixin.dart';

import 'package:vos_flutter/feature/news/domain/models/news.dart';

import 'package:vos_flutter/feature/news/domain/usecases/get_news_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/get_article_detail_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/search_news_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/create_article_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/update_article_usecase.dart';

import 'package:vos_flutter/feature/news/domain/usecases/delete_article_usecase.dart';

class NewsController extends BaseController
    with ApiResultMixin, PaginationMixin<News> {
  final GetNewsUsecase getNewsUsecase;

  final GetArticleDetailUsecase getArticleDetailUsecase;

  final SearchNewsUsecase searchNewsUsecase;

  final CreateArticleUsecase createArticleUsecase;

  final UpdateArticleUsecase updateArticleUsecase;

  final DeleteArticleUsecase deleteArticleUsecase;

  RxList<News> get news => items;
  final int pageSize = 10;

  final Rxn<News> selectedNews = Rxn<News>();

  void setSelectedNews(News? value) {
    selectedNews.value = value;
  }

  final RxString searchQuery = ''.obs;

  NewsController({
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
    fetchPage(1);
  }

  void _replaceList(List<News> data, {bool append = false}) {
    if (append) {
      appendPage(data);
    } else {
      items.assignAll(data);
    }
  }

  @override
  Future<void> fetchPage(int page) async {
    await getNews(page: page, limit: pageSize);
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

    await searchNews(query, page: 1, limit: pageSize);
  }

  Future<void> getNews({int page = 1, int limit = 10}) async {
    await handleApiCall<List<News>>(
      apiCall: () => getNewsUsecase.call(page: page, limit: limit),
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

  Future<void> searchNews(String query, {int page = 1, int limit = 10}) async {
    await handleApiCall<List<News>>(
      apiCall: () => searchNewsUsecase.call(query, page: page, limit: limit),
      onSuccess: (data) {
        if (page == 1) {
          _replaceList(data);
        } else {
          _replaceList(data, append: true);
        }
      },
    );
  }

  Future<void> createArticle(News item) async {
    final success = await handleApiCallVoid(
      apiCall: () => createArticleUsecase.call(item),
    );
    if (success) {
      await onRefresh();
    }
  }

  Future<void> updateArticle(News item) async {
    await handleApiCall<bool>(
      apiCall: () => updateArticleUsecase.call(item),
      onSuccess: (data) {
        final updatedItem = item;
        final listRef = items;
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
          items.removeWhere((element) => element.id == id);
        }
      },
    );
  }
}
