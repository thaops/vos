// import 'package:dio/dio.dart';
// import 'package:vos_flutter/common/repositoty/dio_api.dart';
// import 'package:vos_flutter/common/utils/api_response_handler.dart';

// /// Ví dụ về cách sử dụng ApiResponseHandler trong các service khác
// class TaskService {
//   final DioApi _dioApi = DioApi();

//   /// Ví dụ: Lấy danh sách tasks
//   Future<ApiResult<List<TaskModel>>> getTasks() async {
//     try {
//       final response = await _dioApi.get('/api/tasks');

//       return ApiResponseHandler.handleListResponse<TaskModel>(
//         response,
//         TaskModel.fromJson,
//       );
//     } catch (e) {
//       return ApiResult<List<TaskModel>>.error('Network error: $e');
//     }
//   }

//   /// Ví dụ: Lấy chi tiết task
//   Future<ApiResult<TaskModel>> getTaskById(String taskId) async {
//     try {
//       final response = await _dioApi.get('/api/tasks/$taskId');

//       return ApiResponseHandler.handleResponse<TaskModel>(
//         response,
//         TaskModel.fromJson,
//       );
//     } catch (e) {
//       return ApiResult<TaskModel>.error('Network error: $e');
//     }
//   }

//   /// Ví dụ: Tạo task mới
//   Future<ApiResult<TaskModel>> createTask(Map<String, dynamic> taskData) async {
//     try {
//       final response = await _dioApi.post('/api/tasks', data: taskData);

//       return ApiResponseHandler.handleResponse<TaskModel>(
//         response,
//         TaskModel.fromJson,
//       );
//     } catch (e) {
//       return ApiResult<TaskModel>.error('Network error: $e');
//     }
//   }

//   /// Ví dụ: Cập nhật task
//   Future<ApiResult<TaskModel>> updateTask(
//     String taskId,
//     Map<String, dynamic> taskData,
//   ) async {
//     try {
//       final response = await _dioApi.put('/api/tasks/$taskId', data: taskData);

//       return ApiResponseHandler.handleResponse<TaskModel>(
//         response,
//         TaskModel.fromJson,
//       );
//     } catch (e) {
//       return ApiResult<TaskModel>.error('Network error: $e');
//     }
//   }
// }

// /// Ví dụ model
// class TaskModel {
//   final String id;
//   final String name;
//   final String status;

//   TaskModel({required this.id, required this.name, required this.status});

//   factory TaskModel.fromJson(Map<String, dynamic> json) {
//     return TaskModel(
//       id: json['id'] ?? '',
//       name: json['name'] ?? '',
//       status: json['status'] ?? '',
//     );
//   }
// }

// /// Ví dụ controller sử dụng service
// class TaskController {
//   final TaskService _taskService = TaskService();

//   // Observable variables
//   final RxList<TaskModel> tasks = <TaskModel>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxString error = ''.obs;

//   /// Load danh sách tasks
//   Future<void> loadTasks() async {
//     try {
//       isLoading.value = true;
//       error.value = '';

//       final result = await _taskService.getTasks();

//       if (result.isSuccess) {
//         tasks.value = result.data!;
//       } else {
//         error.value = result.error ?? 'Lỗi không xác định';
//       }
//     } catch (e) {
//       error.value = 'Đã xảy ra lỗi: $e';
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   /// Tạo task mới
//   Future<bool> createTask(Map<String, dynamic> taskData) async {
//     try {
//       final result = await _taskService.createTask(taskData);

//       if (result.isSuccess) {
//         // Thêm task mới vào danh sách
//         tasks.add(result.data!);
//         return true;
//       } else {
//         error.value = result.error ?? 'Lỗi tạo task';
//         return false;
//       }
//     } catch (e) {
//       error.value = 'Đã xảy ra lỗi: $e';
//       return false;
//     }
//   }
// }
