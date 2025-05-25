// pubspec.yaml
/*
name: clothing_app
description: A Flutter application for managing clothing items

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
*/

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ClothingApp());
}

class ClothingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clothing Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ClothingListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// models/clothing.dart
class Clothing {
  final int? id;
  final String name;
  final int price;
  final String category;
  final String brand;
  final int sold;
  final double rating;
  final int stock;
  final int yearReleased;
  final String material;

  Clothing({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.brand,
    required this.sold,
    required this.rating,
    required this.stock,
    required this.yearReleased,
    required this.material,
  });

  factory Clothing.fromJson(Map<String, dynamic> json) {
    return Clothing(
      id: json['id'],
      name: json['name'] ?? '',
      price: _parseToInt(json['price']),
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      sold: _parseToInt(json['sold']),
      rating: _parseToDouble(json['rating']),
      stock: _parseToInt(json['stock']),
      yearReleased: _parseToInt(json['yearReleased']),
      material: json['material'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'brand': brand,
      'sold': sold,
      'rating': rating,
      'stock': stock,
      'yearReleased': yearReleased,
      'material': material,
    };
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

// services/api_service.dart
class ApiService {
  static const String baseUrl =
      'https://tpm-api-tugas-872136705893.us-central1.run.app/api';

  static Future<List<Clothing>> getClothes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clothes'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'] ?? [];
        return data.map((item) => Clothing.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load clothes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Clothing> getClothingById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/clothes/$id'));
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Clothing.fromJson(jsonResponse['data'] ?? jsonResponse);
      } else {
        throw Exception('Failed to load clothing detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<bool> createClothing(Clothing clothing) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/clothes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(clothing.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateClothing(int id, Clothing clothing) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/clothes/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(clothing.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteClothing(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/clothes/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

// screens/clothing_list_screen.dart
class ClothingListScreen extends StatefulWidget {
  @override
  _ClothingListScreenState createState() => _ClothingListScreenState();
}

class _ClothingListScreenState extends State<ClothingListScreen> {
  List<Clothing> clothes = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadClothes();
  }

  Future<void> loadClothes() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final clothesList = await ApiService.getClothes();
      setState(() {
        clothes = clothesList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating && rating % 1 >= 0.5)
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber,
          size: 14,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clothing Management'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: loadClothes,
        child:
            isLoading
                ? Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(error, style: TextStyle(color: Colors.red)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: loadClothes,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
                : clothes.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No clothes found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
                : Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: clothes.length,
                    // In the GridView.builder itemBuilder:
                    itemBuilder: (context, index) {
                      final clothing = clothes[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ClothingDetailScreen(
                                      clothingId: clothing.id!,
                                      onChanged: loadClothes,
                                    ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image placeholder
                                Container(
                                  height: 80,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.checkroom,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Name with flexible height
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: 40,
                                  ), // Limit to 2 lines
                                  child: Text(
                                    clothing.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14, // Reduced from 16
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Brand - single line
                                Text(
                                  clothing.brand,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12, // Reduced from 14
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                // Price
                                Text(
                                  'Rp ${clothing.price.toString()}',
                                  style: TextStyle(
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Reduced from 16
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Category chip
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ), // Reduced padding
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    clothing.category,
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 10, // Reduced from 12
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 4),

                                Spacer(),
                                // Rating row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStarRating(clothing.rating),
                                    Text(
                                      '${clothing.rating}',
                                      style: TextStyle(
                                        fontSize: 10, // Reduced from 12
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClothingFormScreen(onSaved: loadClothes),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[600],
      ),
    );
  }
}

// screens/clothing_detail_screen.dart
class ClothingDetailScreen extends StatefulWidget {
  final int clothingId;
  final VoidCallback onChanged;

  ClothingDetailScreen({required this.clothingId, required this.onChanged});

  @override
  _ClothingDetailScreenState createState() => _ClothingDetailScreenState();
}

class _ClothingDetailScreenState extends State<ClothingDetailScreen> {
  Clothing? clothing;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadClothingDetail();
  }

  Future<void> loadClothingDetail() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final clothingDetail = await ApiService.getClothingById(
        widget.clothingId,
      );
      setState(() {
        clothing = clothingDetail;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> deleteClothing() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteClothing(widget.clothingId);
      if (success) {
        widget.onChanged();
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Item deleted successfully')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete item')));
      }
    }
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating && rating % 1 >= 0.5)
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber,
          size: 24,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clothing Detail'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (clothing != null) ...[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ClothingFormScreen(
                          clothing: clothing,
                          onSaved: () {
                            widget.onChanged();
                            loadClothingDetail();
                          },
                        ),
                  ),
                );
              },
            ),
            IconButton(icon: Icon(Icons.delete), onPressed: deleteClothing),
          ],
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : error.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(error, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loadClothingDetail,
                      child: Text('Retry'),
                    ),
                  ],
                ),
              )
              : clothing == null
              ? Center(child: Text('Clothing not found'))
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.checkroom,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      clothing!.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      clothing!.brand,
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Rp ${clothing!.price.toString()}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildDetailRow('Category', clothing!.category),
                            SizedBox(height: 12),
                            _buildDetailRow('Material', clothing!.material),
                            SizedBox(height: 12),
                            _buildDetailRow(
                              'Year Released',
                              clothing!.yearReleased.toString(),
                            ),
                            SizedBox(height: 12),
                            _buildDetailRow(
                              'Stock',
                              clothing!.stock.toString(),
                            ),
                            SizedBox(height: 12),
                            _buildDetailRow('Sold', clothing!.sold.toString()),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'Rating: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildStarRating(clothing!.rating),
                                SizedBox(width: 8),
                                Text(
                                  '(${clothing!.rating}/5)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
      ],
    );
  }
}

// screens/clothing_form_screen.dart
class ClothingFormScreen extends StatefulWidget {
  final Clothing? clothing;
  final VoidCallback onSaved;

  ClothingFormScreen({this.clothing, required this.onSaved});

  @override
  _ClothingFormScreenState createState() => _ClothingFormScreenState();
}

class _ClothingFormScreenState extends State<ClothingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _soldController = TextEditingController();
  final _stockController = TextEditingController();
  final _yearReleasedController = TextEditingController();
  final _materialController = TextEditingController();
  double _rating = 1.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.clothing != null) {
      _nameController.text = widget.clothing!.name;
      _priceController.text = widget.clothing!.price.toString();
      _categoryController.text = widget.clothing!.category;
      _brandController.text = widget.clothing!.brand;
      _soldController.text = widget.clothing!.sold.toString();
      _stockController.text = widget.clothing!.stock.toString();
      _yearReleasedController.text = widget.clothing!.yearReleased.toString();
      _materialController.text = widget.clothing!.material;
      _rating = widget.clothing!.rating;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _soldController.dispose();
    _stockController.dispose();
    _yearReleasedController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  Future<void> saveClothing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final clothing = Clothing(
      id: widget.clothing?.id,
      name: _nameController.text,
      price: int.parse(_priceController.text),
      category: _categoryController.text,
      brand: _brandController.text,
      sold: int.parse(_soldController.text),
      rating: _rating,
      stock: int.parse(_stockController.text),
      yearReleased: int.parse(_yearReleasedController.text),
      material: _materialController.text,
    );

    bool success;
    if (widget.clothing == null) {
      success = await ApiService.createClothing(clothing);
    } else {
      success = await ApiService.updateClothing(widget.clothing!.id!, clothing);
    }

    setState(() {
      isLoading = false;
    });

    if (success) {
      widget.onSaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.clothing == null
                ? 'Clothing added successfully'
                : 'Clothing updated successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save clothing')));
    }
  }

  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = (index + 1).toDouble();
                  });
                },
                child: Icon(
                  index < _rating.floor()
                      ? Icons.star
                      : (index < _rating && _rating % 1 >= 0.5)
                      ? Icons.star_half
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
            SizedBox(width: 16),
            Text(
              _rating.toString(),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Slider(
          value: _rating,
          min: 0.0,
          max: 5.0,
          divisions: 50,
          label: _rating.toString(),
          onChanged: (value) {
            setState(() {
              _rating = value;
            });
          },
        ),
        SizedBox(height: 4),
        Text(
          '$_rating out of 5 stars',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clothing == null ? 'Add Clothing' : 'Edit Clothing'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: isLoading ? null : saveClothing,
            child: Text(
              'SAVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter clothing name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _brandController,
                label: 'Brand',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter brand';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _priceController,
                label: 'Price',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _categoryController,
                label: 'Category',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _materialController,
                label: 'Material',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter material';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _stockController,
                label: 'Stock',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter valid stock number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _soldController,
                label: 'Sold',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sold amount';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter valid sold number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _yearReleasedController,
                label: 'Year Released',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter year released';
                  }
                  final year = int.tryParse(value);
                  if (year == null) {
                    return 'Please enter valid year';
                  }
                  if (year < 2018 || year > 2025) {
                    return 'Year must be between 2018 and 2025';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              _buildStarRating(),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveClothing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            widget.clothing == null
                                ? 'ADD CLOTHING'
                                : 'UPDATE CLOTHING',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[600]!),
        ),
      ),
    );
  }
}
