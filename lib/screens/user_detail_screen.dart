import 'dart:io';

import 'package:assignment_appscrip/screens/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:cached_network_image/cached_network_image.dart';
import '../model/user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;
  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(user.name),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareUserInfo,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent.shade100,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              "Username: ${user.username}",
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),

            // Email Card
            _buildInfoCard(
              context,
              icon: Icons.email,
              title: "Email",
              value: user.email,
              color: Colors.redAccent,
              onTap: () => _launchEmail(user.email),
            ),
            const SizedBox(height: 12),

            // Phone Card
            _buildInfoCard(
              context,
              icon: Icons.phone,
              title: "Phone",
              value: user.phone,
              color: Colors.green,
              onTap: () => _launchPhone(user.phone),
            ),
            const SizedBox(height: 12),

            // Website Card
            _buildInfoCard(
              context,
              icon: Icons.language,
              title: "Website",
              value: user.website,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(
                      url: "https://${user.website}",
                      title: user.website,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Address Card with Map Preview
            _buildAddressCard(context),

            const SizedBox(height: 12),

            // Company Card
            _buildInfoCard(
              context,
              icon: Icons.business,
              title: "Company",
              value:
              "${user.company.name}\n${user.company.catchPhrase}\n${user.company.bs}",
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String value,
        required Color color,
        VoidCallback? onTap,
      }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
            : null,
        onTap: onTap,
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("$title copied!")));
        },
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    final address =
        "${user.address.street}, ${user.address.suite}, ${user.address.city}, ${user.address.zipcode}";

    final lat = user.address.geo.lat;
    final lng = user.address.geo.lng;

    final double latitude = double.tryParse(lat) ?? 0.0;
    final double longitude = double.tryParse(lng) ?? 0.0;

    final mapUrl =
        "https://maps.googleapis.com/maps/api/staticmap"
        "?center=$latitude,$longitude"
        "&zoom=15"
        "&size=600x300"
        "&markers=color:red%7C$latitude,$longitude"
        "&key=AIzaSyAWbWNOIN2NVRIHbjhflvEh4JDr2ZkJ3xA"; // Replace with your key

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final double latitude = double.tryParse(user.address.geo.lat) ?? 0.0;
          final double longitude = double.tryParse(user.address.geo.lng) ?? 0.0;
          _openMap(latitude, longitude, label: user.name);
        },
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.withOpacity(0.1),
                child: const Icon(Icons.home, color: Colors.deepPurple),
              ),
              title: const Text("Address",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: Text(address, style: const TextStyle(fontSize: 15)),
              trailing: const Icon(Icons.map, color: Colors.deepPurple),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: address));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Address copied!")));
              },
            ),
            // Map Preview
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: mapUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await launcher.canLaunchUrl(emailUri)) {
      await launcher.launchUrl(emailUri, mode: launcher.LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch email app");
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (await launcher.canLaunchUrl(phoneUri)) {
      await launcher.launchUrl(phoneUri, mode: launcher.LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch phone app");
    }
  }


  void _openMap(double latitude, double longitude, {String label = 'Location'}) async {
    String url = '';

    if (Platform.isAndroid) {
      // Android: use geo URI
      url = 'geo:$latitude,$longitude?q=$latitude,$longitude($label)';
    } else if (Platform.isIOS) {
      // iOS: use Apple Maps
      url = 'http://maps.apple.com/?ll=$latitude,$longitude&q=$label';
    } else {
      // Fallback to Google Maps in browser
      url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    }

    final Uri uri = Uri.parse(url);
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }


  void _shareUserInfo() {
    final text = '''
👤 ${user.name} (${user.username})
📧 ${user.email}
📞 ${user.phone}
🌐 ${user.website}
🏢 ${user.company.name} - ${user.company.catchPhrase}, ${user.company.bs}
🏠 ${user.address.street}, ${user.address.suite}, ${user.address.city}, ${user.address.zipcode}
🌍 Geo: ${user.address.geo.lat}, ${user.address.geo.lng}
''';
    Share.share(text, subject: "User Info: ${user.name}");
  }
}
