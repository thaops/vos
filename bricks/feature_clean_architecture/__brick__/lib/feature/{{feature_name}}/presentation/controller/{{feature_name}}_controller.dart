import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/common/mixins/api_result_mixin.dart';
{{#has_pagination}}
import 'package:vos_flutter/common/mixins/pagination_mixin.dart';
{{/has_pagination}}
import 'package:vos_flutter/feature/{{feature_name}}/domain/models/{{model_name}}.dart';
{{#parsed_usecases}}
import 'package:vos_flutter/feature/{{feature_name}}/domain/usecases/{{snakeName}}_usecase.dart';
{{/parsed_usecases}}

class {{feature_name.pascalCase()}}Controller extends BaseController
    with ApiResultMixin{{#has_pagination}}, PaginationMixin<{{model_name_pascal}}>{{/has_pagination}} {
  {{#parsed_usecases}}
  final {{className}} {{camelName}}Usecase;
  {{/parsed_usecases}}

  {{#has_list_usecase}}
  {{#has_pagination}}
  RxList<{{model_name_pascal}}> get {{model_plural_camel}} => items;
  final int pageSize = 10;
  {{/has_pagination}}
  {{^has_pagination}}
  final RxList<{{model_name_pascal}}> {{model_plural_camel}} = <{{model_name_pascal}}> [].obs;
  {{/has_pagination}}
  {{/has_list_usecase}}

  {{#has_detail_usecase}}
  final Rxn<{{model_name_pascal}}> selected{{model_name_pascal}} = Rxn<{{model_name_pascal}}>();

  void setSelected{{model_name_pascal}}({{model_name_pascal}}? value) {
    selected{{model_name_pascal}}.value = value;
  }
  {{/has_detail_usecase}}

  {{#search_usecase}}
  final RxString searchQuery = ''.obs;
  {{/search_usecase}}

  {{feature_name.pascalCase()}}Controller({
    {{#parsed_usecases}}required this.{{camelName}}Usecase,
    {{/parsed_usecases}}
  });

  {{#has_list_usecase}}
  void _replaceList(List<{{model_name_pascal}}> data, {bool append = false}) {
    {{#has_pagination}}
    if (append) {
      appendPage(data);
    } else {
      items.assignAll(data);
    }
    {{/has_pagination}}
    {{^has_pagination}}
    if (append) {
      {{model_plural_camel}}.addAll(data);
    } else {
      {{model_plural_camel}}.assignAll(data);
    }
    {{/has_pagination}}
  }
  {{/has_list_usecase}}

  {{#has_pagination}}
  @override
  Future<void> fetchPage(int page) async {
    {{#first_list_usecase}}
    await {{camelName}}(page: page, limit: pageSize);
    {{/first_list_usecase}}
  }

  Future<void> onRefresh() async {
    resetPagination();
    await fetchPage(1);
  }

  Future<void> onLoadMore() async {
    await loadNextPage();
  }
  {{/has_pagination}}

  {{^has_pagination}}
  {{#has_list_usecase}}
  Future<void> onRefresh() async {
    {{#first_list_usecase}}
    await {{camelName}}();
    {{/first_list_usecase}}
  }
  {{/has_list_usecase}}
  {{/has_pagination}}

  {{#search_usecase}}
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  Future<void> onSearch(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      {{#has_list_usecase}}
      {{#has_pagination}}
      await onRefresh();
      {{/has_pagination}}
      {{^has_pagination}}
      {{#first_list_usecase}}
      await {{camelName}}();
      {{/first_list_usecase}}
      {{/has_pagination}}
      {{/has_list_usecase}}
      return;
    }

    {{#search_usecase}}
    await {{camelName}}(
      query,
      {{#supportsPagination}}
      page: 1,
      limit: {{#has_pagination}}pageSize{{/has_pagination}}{{^has_pagination}}10{{/has_pagination}},
      {{/supportsPagination}}
    );
    {{/search_usecase}}
  }
  {{/search_usecase}}

{{#parsed_usecases}}
  Future<void> {{camelName}}({{#hasParams}}{{domainMethodParams}}{{/hasParams}}) async {
    {{#isVoidReturn}}
    final success = await handleApiCallVoid(
      apiCall: () => {{camelName}}Usecase.call({{#hasParams}}{{methodCallArgs}}{{/hasParams}}),
    );
    if (success) {
      {{#isDelete}}
      {{#has_list_usecase}}
      {{#has_pagination}}
      items.removeWhere((element) => element.id == id);
      {{/has_pagination}}
      {{^has_pagination}}
      {{model_plural_camel}}.removeWhere((element) => element.id == id);
      {{/has_pagination}}
      {{/has_list_usecase}}
      {{/isDelete}}
      {{^isDelete}}
      {{#has_list_usecase}}
      {{#has_pagination}}
      await onRefresh();
      {{/has_pagination}}
      {{^has_pagination}}
      {{#first_list_usecase}}
      await {{camelName}}();
      {{/first_list_usecase}}
      {{/has_pagination}}
      {{/has_list_usecase}}
      {{/isDelete}}
    }
    {{/isVoidReturn}}
    {{^isVoidReturn}}
    await handleApiCall<{{#isList}}List<{{model_name_pascal}}>{{/isList}}{{^isList}}{{#isDetail}}{{model_name_pascal}}{{/isDetail}}{{^isDetail}}{{returnType}}{{/isDetail}}{{/isList}}>(
      apiCall: () => {{camelName}}Usecase.call({{#hasParams}}{{methodCallArgs}}{{/hasParams}}),
      onSuccess: (data) {
        {{#isList}}
        {{#supportsPagination}}
        if (page == 1) {
          _replaceList(data);
        } else {
          _replaceList(data, append: true);
        }
        {{/supportsPagination}}
        {{^supportsPagination}}
        _replaceList(data);
        {{/supportsPagination}}
        {{/isList}}
        {{#isDetail}}
        selected{{model_name_pascal}}.value = data;
        {{/isDetail}}
        {{#isUpdate}}
        {{#has_list_usecase}}
        final updatedItem = {{#returnsDomainEntity}}data{{/returnsDomainEntity}}{{^returnsDomainEntity}}item{{/returnsDomainEntity}};
        final listRef = {{#has_pagination}}items{{/has_pagination}}{{^has_pagination}}{{model_plural_camel}}{{/has_pagination}};
        final index = listRef.indexWhere((element) => element.id == updatedItem.id);
        if (index != -1) {
          listRef[index] = updatedItem;
          listRef.refresh();
        }
        {{/has_list_usecase}}
        {{/isUpdate}}
        {{#isDelete}}
        {{#has_list_usecase}}
        {{#isBoolReturn}}
        if (data) {
        {{/isBoolReturn}}
        {{#has_pagination}}
        items.removeWhere((element) => element.id == id);
        {{/has_pagination}}
        {{^has_pagination}}
        {{model_plural_camel}}.removeWhere((element) => element.id == id);
        {{/has_pagination}}
        {{#isBoolReturn}}
        }
        {{/isBoolReturn}}
        {{/has_list_usecase}}
        {{/isDelete}}
      },
    );
    {{/isVoidReturn}}
  }

{{/parsed_usecases}}
}


