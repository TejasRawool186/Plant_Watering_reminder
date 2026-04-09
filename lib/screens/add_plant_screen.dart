import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/plant_provider.dart';
import '../theme/app_theme.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  int _wateringFrequency = 3;
  DateTime _lastWatered = DateTime.now();
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  bool _isSaving = false;
  String? _selectedImagePath;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  static const List<IconData> _plantIcons = [
    Icons.eco_rounded,
    Icons.yard_rounded,
    Icons.local_florist_rounded,
    Icons.grass_rounded,
    Icons.forest_rounded,
    Icons.spa_rounded,
    Icons.energy_savings_leaf_rounded,
    Icons.nature_rounded,
  ];

  static const List<Color> _plantColors = [
    Color(0xFF52B788),
    Color(0xFF40916C),
    Color(0xFF2D6A4F),
    Color(0xFF95D5B2),
    Color(0xFF74C69D),
    Color(0xFF1B9AAA),
    Color(0xFF06D6A0),
    Color(0xFFE76F51),
    Color(0xFFF4A261),
    Color(0xFFE9C46A),
    Color(0xFF264653),
    Color(0xFF9B5DE5),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Add New Plant',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppTheme.cardShadow,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            children: [
              // Plant Preview
              _buildPreviewCard(),
              const SizedBox(height: 28),

              // Plant Name
              _buildSectionTitle('Plant Name', Icons.edit_rounded),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g. Peace Lily, Snake Plant...',
                  prefixIcon: Icon(Icons.eco_rounded, color: AppTheme.primary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a plant name';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 28),

              // Icon Selector
              _buildSectionTitle('Choose Icon', Icons.emoji_nature_rounded),
              const SizedBox(height: 10),
              _buildIconSelector(),
              const SizedBox(height: 28),

              // Color Selector
              _buildSectionTitle('Choose Color', Icons.palette_rounded),
              const SizedBox(height: 10),
              _buildColorSelector(),
              const SizedBox(height: 28),

              // Watering Frequency
              _buildSectionTitle(
                  'Watering Frequency', Icons.water_drop_rounded),
              const SizedBox(height: 10),
              _buildFrequencySelector(),
              const SizedBox(height: 28),

              // Last Watered
              _buildSectionTitle('Last Watered', Icons.calendar_today_rounded),
              const SizedBox(height: 10),
              _buildDatePicker(),
              const SizedBox(height: 40),

              // Save Button
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    final selectedColor = _plantColors[_selectedColorIndex];
    final selectedIcon = _plantIcons[_selectedIconIndex];
    final name = _nameController.text.isNotEmpty
        ? _nameController.text
        : 'Your Plant';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            selectedColor.withValues(alpha: 0.12),
            selectedColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: selectedColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        selectedColor.withValues(alpha: 0.25),
                        selectedColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: selectedColor.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: _selectedImagePath != null
                        ? DecorationImage(
                            image: kIsWeb
                                ? NetworkImage(_selectedImagePath!) as ImageProvider
                                : FileImage(File(_selectedImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImagePath == null
                      ? Icon(selectedIcon, size: 40, color: selectedColor)
                      : null,
                ),
                Positioned(
                  bottom: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add_a_photo_rounded, size: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Water every $_wateringFrequency ${_wateringFrequency == 1 ? 'day' : 'days'}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
            label: Text(_selectedImagePath == null ? 'Upload Photo' : 'Change Photo'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(_plantIcons.length, (index) {
          final isSelected = _selectedIconIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIconIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? _plantColors[_selectedColorIndex].withValues(alpha: 0.15)
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? _plantColors[_selectedColorIndex]
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                _plantIcons[index],
                color: isSelected
                    ? _plantColors[_selectedColorIndex]
                    : AppTheme.textLight,
                size: 24,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_plantColors.length, (index) {
          final isSelected = _selectedColorIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedColorIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _plantColors[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _plantColors[index].withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 20)
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFrequencyButton(Icons.remove_rounded, () {
                if (_wateringFrequency > 1) {
                  setState(() => _wateringFrequency--);
                }
              }),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '$_wateringFrequency',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                  Text(
                    _wateringFrequency == 1 ? 'day' : 'days',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              _buildFrequencyButton(Icons.add_rounded, () {
                if (_wateringFrequency < 90) {
                  setState(() => _wateringFrequency++);
                }
              }),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primary,
              inactiveTrackColor: AppTheme.accentLight,
              thumbColor: AppTheme.primary,
              overlayColor: AppTheme.primary.withValues(alpha: 0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _wateringFrequency.toDouble(),
              min: 1,
              max: 90,
              onChanged: (value) {
                setState(() => _wateringFrequency = value.round());
              },
            ),
          ),
          // Quick presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPresetChip('Daily', 1),
              _buildPresetChip('3 days', 3),
              _buildPresetChip('Weekly', 7),
              _buildPresetChip('Bi-weekly', 14),
              _buildPresetChip('Monthly', 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primary),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, int days) {
    final isSelected = _wateringFrequency == days;
    return GestureDetector(
      onTap: () => setState(() => _wateringFrequency = days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _lastWatered,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppTheme.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppTheme.textPrimary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _lastWatered = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d').format(_lastWatered),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('yyyy').format(_lastWatered),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _savePlant,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppTheme.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Save Plant',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _savePlant() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await context.read<PlantProvider>().addPlant(
          name: _nameController.text.trim(),
          wateringFrequency: _wateringFrequency,
          lastWatered: _lastWatered,
          imagePath: _selectedImagePath,
          icon: _plantIcons[_selectedIconIndex],
          color: _plantColors[_selectedColorIndex],
        );

    if (mounted) {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🌱 ${_nameController.text.trim()} added!'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.of(context).pop();
    }
  }
}
