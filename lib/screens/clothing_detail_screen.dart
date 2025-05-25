import 'package:flutter/material.dart';
import 'package:tugasmobile7/services/api_service.dart';
import 'package:tugasmobile7/models/clothing.dart';
import 'clothing_form_screen.dart';

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
