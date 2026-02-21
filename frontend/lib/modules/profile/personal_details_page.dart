import 'package:flutter/material.dart';

/// Personal Details form: profile photo, personal info, professional details, additional info.
/// Accessed via profile button in header.
class PersonalDetailsPage extends StatefulWidget {
  const PersonalDetailsPage({super.key});

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController(text: 'John Doe');
  final _email = TextEditingController(text: 'john@example.com');
  final _phone = TextEditingController(text: '+1 (555) 000-0000');
  final _currentPosition = TextEditingController(text: 'Project Manager');
  final _homeAddress = TextEditingController();
  final _professionalDescription = TextEditingController();
  final _likesInterests = TextEditingController();
  String? _marriageStatus;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _currentPosition.dispose();
    _homeAddress.dispose();
    _professionalDescription.dispose();
    _likesInterests.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Personal Details'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: GestureDetector(
                onTap: () => _pickImage(context),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 20,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to change photo',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 28),
            _sectionLabel(theme, 'Personal Details'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fullName,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'John Doe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _marriageStatus,
              decoration: const InputDecoration(
                labelText: 'Marriage Status',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Select status'),
              items: ['Single', 'Married', 'Divorced', 'Widowed']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _marriageStatus = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'john@example.com',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 (555) 000-0000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 28),
            _sectionLabel(theme, 'PROFESSIONAL DETAILS'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _currentPosition,
              decoration: const InputDecoration(
                labelText: 'Current Position',
                hintText: 'Project Manager',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            _ResumeUploadZone(
              onUpload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resume upload coming soon')),
                );
              },
            ),
            const SizedBox(height: 28),
            _sectionLabel(theme, 'ADDITIONAL INFORMATION'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _homeAddress,
              decoration: const InputDecoration(
                labelText: 'Home Address',
                hintText: 'Enter your full residential address',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _professionalDescription,
              decoration: const InputDecoration(
                labelText: 'Professional Description',
                hintText: 'Briefly describe your professional journey...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _likesInterests,
              decoration: const InputDecoration(
                labelText: 'Likes & Interests',
                hintText: 'Music, traveling, strategy games...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveAndContinue,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                label: const Text('Save and Continue'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo picker coming soon')),
    );
  }

  void _saveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Details saved')),
      );
      Navigator.of(context).pop();
    }
  }
}

class _ResumeUploadZone extends StatelessWidget {
  const _ResumeUploadZone({required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onUpload,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Click to upload PDF',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Maximum file size 5MB',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
