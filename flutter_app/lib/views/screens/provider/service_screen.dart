import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:homeservice/views/screens/provider/service_providers_screen.dart';

class AllCategoriesScreen extends StatefulWidget {
  final List<dynamic> allCategories;
  final String clientId;

  const AllCategoriesScreen(
      {super.key, required this.allCategories, required this.clientId});

  @override
  _AllCategoriesScreenState createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  bool isGridView = true;
  String searchQuery = "";
  List<dynamic> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    filteredCategories = widget.allCategories;
  }

  void _toggleViewMode() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  void _filterCategories(String query) {
    setState(() {
      searchQuery = query;
      filteredCategories = widget.allCategories.where((cat) {
        final name = cat['category_name']?.toString().toLowerCase() ?? "";
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget _buildCategoryIcon(String? base64Icon) {
    if (base64Icon == null || base64Icon.isEmpty) {
      return Icon(Icons.home_repair_service, color: Color(0xFF5464FD));
    }
    try {
      Uint8List imageBytes = base64Decode(base64Icon);
      return Image.memory(
        imageBytes,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Icon(Icons.home_repair_service, color: Color(0xFF5464FD));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الفئات"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.view_module),
            onPressed: _toggleViewMode,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterCategories,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: "ابحث هنا",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: isGridView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(8),
      itemCount: filteredCategories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        final iconWidget = _buildCategoryIcon(category['icon']);
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryProvidersScreen(
                  categoryId: category['id'].toString(),
                  categoryName: category['category_name'],
                  clientId: widget.clientId,
                  selectedServiceName: '',
                  selectedServiceId: '',
                ),
              ),
            );
          },
          child: Column(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: iconWidget),
              ),
              SizedBox(height: 5),
              Text(
                category['category_name'] ?? "",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      itemCount: filteredCategories.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        final iconWidget = _buildCategoryIcon(category['icon']);
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: iconWidget),
          ),
          title: Text(
            category['category_name'] ?? "",
            textAlign: TextAlign.right,
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryProvidersScreen(
                  categoryId: category['id'].toString(),
                  categoryName: category['category_name'],
                  clientId: widget.clientId,
                  selectedServiceName: '',
                  selectedServiceId: '',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
