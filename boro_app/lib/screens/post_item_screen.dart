import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/item_provider.dart';
import '../utils/constants.dart';

class PostItemScreen extends StatefulWidget {
  const PostItemScreen({super.key});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategoryId;
  String _selectedCondition = 'good';
  final List<XFile> _images = [];
  bool _allowNegotiation = true;
  bool _isLoading = false;

  final _picker = ImagePicker();

  final _conditions = [
    {'value': 'new', 'label': 'New'},
    {'value': 'like_new', 'label': 'Like New'},
    {'value': 'good', 'label': 'Good'},
    {'value': 'fair', 'label': 'Fair'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) setState(() => _images.addAll(picked));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // In production: upload images first, then create item
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item listed successfully! 🎉'), backgroundColor: AppColors.primary),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('List an item'),
        backgroundColor: AppColors.surface,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildSection('Item details', [
              _buildField(_titleController, 'Item name', hint: 'e.g. Bosch Power Drill',
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _buildField(_descController, 'Description', hint: 'Describe your item, its condition, and what\'s included',
                  maxLines: 4, validator: (v) => v!.isEmpty ? 'Required' : null),
            ]),
            const SizedBox(height: 16),
            _buildSection('Category', [_buildCategoryGrid()]),
            const SizedBox(height: 16),
            _buildSection('Condition', [_buildConditionRow()]),
            const SizedBox(height: 16),
            _buildSection('Pricing', [
              Row(
                children: [
                  Expanded(child: _buildField(_priceController, 'Price / day (৳)',
                      hint: '120', keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_depositController, 'Deposit (৳)',
                      hint: '500', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Allow negotiation', style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                  Switch(
                    value: _allowNegotiation,
                    onChanged: (v) => setState(() => _allowNegotiation = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Location', [
              _buildField(_locationController, 'Your area', hint: 'e.g. Dhanmondi, Dhaka'),
            ]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Post listing'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, style: BorderStyle.solid, width: 1.5),
          borderRadius: BorderRadius.circular(14),
          color: AppColors.surface,
        ),
        child: _images.isEmpty
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 32, color: AppColors.textTertiary),
                  SizedBox(height: 8),
                  Text('Add photos', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                  Text('Tap to upload up to 5 photos', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                ],
              )
            : Row(
                children: [
                  ...(_images.take(4).map((img) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: AppColors.textTertiary),
                    ),
                  ))),
                  if (_images.length < 5)
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add, color: AppColors.primary),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {String? hint, int maxLines = 1, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final cats = context.watch<ItemProvider>().categories;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cats.map((cat) {
        final isSelected = _selectedCategoryId == cat.id.toString();
        return GestureDetector(
          onTap: () => setState(() => _selectedCategoryId = cat.id.toString()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              cat.name,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConditionRow() {
    return Row(
      children: _conditions.map((c) {
        final isSelected = _selectedCondition == c['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedCondition = c['value']!),
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                c['label']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
