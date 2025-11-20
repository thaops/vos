import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';

import 'package:vos_flutter/feature/news_detail/domain/models/news_detail.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/get_news_usecase.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/get_article_detail_usecase.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/search_news_usecase.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/create_article_usecase.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/update_article_usecase.dart';

import 'package:vos_flutter/feature/news_detail/domain/usecases/delete_article_usecase.dart';


class NewsDetailController extends BaseController
    with ApiResultMixin {
  
  final GetNewsDetailUsecase getNewsUsecase;
  
  final GetNewsDetailArticleUsecase getArticleDetailUsecase;
  
  final SearchNewsDetailUsecase searchNewsUsecase;
  
  final CreateNewsDetailArticleUsecase createArticleUsecase;
  
  final UpdateNewsDetailArticleUsecase updateArticleUsecase;
  
  final DeleteNewsDetailArticleUsecase deleteArticleUsecase;
  

  
  
  
  final RxList<NewsDetail> newsDetails = <NewsDetail> [].obs;
  
  

  
  final Rxn<NewsDetail> selectedNewsDetail = Rxn<NewsDetail>();

  void setSelectedNewsDetail(NewsDetail? value) {
    selectedNewsDetail.value = value;
  }
  

  
  final RxString searchQuery = ''.obs;
  

  NewsDetailController({
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
    // Lấy news id từ arguments
    final newsId = Get.arguments as String?;
    if (newsId != null && newsId.isNotEmpty) {
      getArticleDetail(newsId);
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

    
    await searchNews(
      query,
      
    );
    
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
        final index = listRef.indexWhere((element) => element.id == updatedItem.id);
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


