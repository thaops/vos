import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/base/base_controller.dart';
import 'package:vos_flutter/feature/{{feature_name}}/presentation/controller/{{feature_name}}_controller.dart';

class {{feature_name.pascalCase()}}Screen extends GetView<{{feature_name.pascalCase()}}Controller> {
  const {{feature_name.pascalCase()}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('{{feature_name.pascalCase()}}'),
      ),
      body: {{#has_list_usecase}}Obx(
        () {
          final data = controller.{{model_plural_camel}};
          if (data.isEmpty && controller.status == ControllerStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (data.isEmpty) {
            return const Center(child: Text('No data'));
          }
          return RefreshIndicator(
            onRefresh: controller.onRefresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(item.title ?? 'Untitled'),
                    subtitle: Text(item.description ?? ''),
                  ),
                );
              },
            ),
          );
        },
      ){{/has_list_usecase}}{{^has_list_usecase}}const Center(
        child: Text('Implement {{feature_name}} content here'),
      ){{/has_list_usecase}},
    );
  }
}


