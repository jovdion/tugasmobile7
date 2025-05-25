import 'package:flutter/material.dart';
import 'package:tugasmobile7/models/clothing.dart';
import 'package:tugasmobile7/services/api_service.dart';

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