
import 'package:tugasmobile7/models/clothing.dart';
import 'package:tugasmobile7/services/api_service.dart';
import 'clothing_detail_screen.dart';
import 'clothing_form_screen.dart';
import 'package:flutter/material.dart';


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
