import 'package:flutter/material.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';
import 'package:vos_flutter/feature/news_v2/models/news_item_model.dart';
import 'package:vos_flutter/feature/news_v2/widgets/news_card.dart';

class NewsView extends StatefulWidget {
  const NewsView({super.key});

  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  // Dữ liệu mẫu - sau này sẽ thay bằng API call
  List<NewsItemModel> _newsList = [];

  @override
  void initState() {
    super.initState();
    _loadNewsData();
  }

  void _loadNewsData() {
    // Dữ liệu mẫu
    setState(() {
      _newsList = [
        NewsItemModel(
          id: '1',
          title:
              'VIAGS TỔ CHỨC THÀNH CÔNG CÁC ĐẠI HỘI CÔNG ĐOÀN CƠ SỞ, TIẾN TỚI ĐẠI HỘI CÔNG ĐOÀN CÔNG TY LẦN THỨ III, NHIỆM KỲ 2025–2030',
          bannerImageUrl:
              'https://s3.hcm-1.cloud.cmctelecom.vn/viags-web/Data/Sites/1/News/6939/z6816304115113_ef17c70162b1a73e12066e86f1f19755.jpg',
          publishDate: DateTime(2025, 11, 12, 11, 51),
          viewCount: 1250,
          likeCount: 89,
          commentCount: 23,
        ),
        NewsItemModel(
          id: '2',
          title:
              'CHƯƠNG TRÌNH ĐÀO TẠO NÂNG CAO NĂNG LỰC CHO ĐỘI NGŨ NHÂN VIÊN VIAGS',
          bannerImageUrl:
              'https://s3.hcm-1.cloud.cmctelecom.vn/viags-web/Data/Sites/1/News/6547/1.jpg',
          publishDate: DateTime(2025, 11, 10, 14, 30),
          viewCount: 980,
          likeCount: 67,
          commentCount: 15,
        ),
        NewsItemModel(
          id: '3',
          title:
              'VIAGS ĐẠT THÀNH TỰU XUẤT SẮC TRONG HOẠT ĐỘNG KINH DOANH QUÝ III/2025',
          bannerImageUrl: '',
          publishDate: DateTime(2025, 11, 8, 9, 15),
          viewCount: 2100,
          likeCount: 145,
          commentCount: 42,
        ),
        NewsItemModel(
          id: '4',
          title:
              'HOẠT ĐỘNG THIỆN NGUYỆN CỦA CÔNG ĐOÀN VIAGS: CHIA SẺ YÊU THƯƠNG ĐẾN CỘNG ĐỒNG',
          bannerImageUrl: '',
          publishDate: DateTime(2025, 11, 5, 16, 45),
          viewCount: 756,
          likeCount: 52,
          commentCount: 18,
        ),
        NewsItemModel(
          id: '5',
          title:
              'HỘI NGHỊ TỔNG KẾT CÔNG TÁC AN TOÀN LAO ĐỘNG VÀ VỆ SINH MÔI TRƯỜNG',
          bannerImageUrl: '',
          publishDate: DateTime(2025, 11, 3, 10, 20),
          viewCount: 1120,
          likeCount: 78,
          commentCount: 29,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tin tức',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _newsList.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                _loadNewsData();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _newsList.length,
                itemBuilder: (context, index) {
                  return NewsCard(
                    newsItem: _newsList[index],
                    onTap: () {
                      // TODO: Navigate to news detail
                    },
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Chưa có tin tức',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
