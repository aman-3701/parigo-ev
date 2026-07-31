import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/parigo_logo.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
class LandingPageScreen extends StatelessWidget {
  const LandingPageScreen({Key? key}) : super(key: key);

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: ParigoLogo(
          textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/privacy'),
            child: const Text('Privacy', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/terms'),
            child: const Text('Terms', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;

          Widget heroText = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Electrify Your\nJourney.',
                style: GoogleFonts.audiowide(
                  fontSize: isDesktop ? 64 : 48,
                  color: AppTheme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Experience the future of ride-hailing with Parigo EV. '
                'Fast, silent, and zero-emissions transportation right at your fingertips.',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 16,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Android link coming soon!')),
                      );
                    },
                    child: SizedBox(
                      height: 50,
                      child: SvgPicture.asset('assets/images/play_store.svg'),
                    ),
                  ),
                  const SizedBox(width: 24),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('iOS link coming soon!')),
                      );
                    },
                    child: SizedBox(
                      height: 50,
                      child: SvgPicture.asset('assets/images/app_store.svg'),
                    ),
                  ),
                ],
              ),
            ],
          );

          Widget heroImage = Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryContainer.withOpacity(0.3),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/images/app_mockup.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 100),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80 : 24,
                    vertical: 40,
                  ),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 1, child: heroText),
                            const SizedBox(width: 80),
                            Expanded(flex: 1, child: heroImage),
                          ],
                        )
                      : Column(
                          children: [
                            heroText,
                            const SizedBox(height: 60),
                            heroImage,
                          ],
                        ),
                ),
                
                _buildFeaturesSection(context, isDesktop),
                _buildSustainabilityTracker(context, isDesktop),
                _buildFareEstimator(context, isDesktop),
                _buildTestimonials(context, isDesktop),
                
                _buildDriverSection(context, isDesktop),
                _buildFAQSection(context, isDesktop),
                
                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  color: AppTheme.surfaceContainer,
                  child: Column(
                    children: [
                      Image.asset('assets/images/app_icon.png', width: 64, height: 64),
                      const SizedBox(height: 16),
                      Text('© 2026 Parigo EV. All rights reserved.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Text('Contact: parigoev@gmail.com', style: TextStyle(color: AppTheme.onSurfaceVariant)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/privacy'),
                            child: const Text('Privacy Policy', style: TextStyle(color: AppTheme.onSurfaceVariant, decoration: TextDecoration.underline)),
                          ),
                          const SizedBox(width: 16),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/terms'),
                            child: const Text('Terms of Service', style: TextStyle(color: AppTheme.onSurfaceVariant, decoration: TextDecoration.underline)),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDesktop) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    
    // On mobile: 24 horizontal padding on each side (48 total) + 16 spacing between 2 cards = 64
    double cardWidth = isDesktop ? 260 : (isMobile ? (screenWidth - 64) / 2 - 1 : 220);
    double spacing = isMobile ? 16 : 40;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isMobile ? 40 : 80,
      ),
      color: AppTheme.background,
      child: Column(
        children: [
          Text(
            'Why Choose Parigo EV?',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurface,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 60),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureCard(
                context,
                icon: Icons.eco,
                title: '100% Electric',
                description: 'Zero emissions, silent rides. Help us build a sustainable future.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.my_location,
                title: 'Live Tracking',
                description: 'Real-time driver location and accurate ETAs for your convenience.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.calendar_month,
                title: 'Scheduled Rides',
                description: 'Book your ride in advance and never worry about being late again.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.money_off,
                title: 'No Surge Pricing',
                description: 'Honest, transparent fares that never multiply during peak hours or rain.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.ac_unit,
                title: 'No Extra AC Charges',
                description: 'Enjoy a cool, comfortable ride without paying a single rupee extra.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.person_outline,
                title: 'Professional Drivers',
                description: 'Well-uniformed, polite, and highly trained drivers for a premium experience.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.cleaning_services,
                title: 'Pristine Cabs',
                description: 'Immaculately clean interiors and exteriors for every single ride.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.water_drop,
                title: 'Free Water Bottles',
                description: 'Stay hydrated with complimentary bottled water provided in every cab.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.sanitizer,
                title: 'Complimentary Tissues',
                description: 'Fresh tissue boxes available in the backseat for your convenience.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.child_care,
                title: 'Candies for Kids',
                description: 'A sweet treat to keep the little ones happy and smiling during the journey.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.newspaper,
                title: 'Daily Newspapers',
                description: 'Catch up on the latest news with fresh daily newspapers available in-cab.',
                width: cardWidth,
                isMobile: isMobile,
              ),
              _buildFeatureCard(
                context,
                icon: Icons.delete_outline,
                title: 'In-Cab Dustbin',
                description: 'Dedicated waste bins to help keep your environment clean and tidy.',
                width: cardWidth,
                isMobile: isMobile,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required String description, double? width, bool isMobile = false}) {
    return Container(
      width: width ?? 260,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
        border: Border.all(color: AppTheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: isMobile ? 24 : 32),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(title, style: TextStyle(fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
          SizedBox(height: isMobile ? 8 : 12),
          Text(description, style: TextStyle(fontSize: isMobile ? 12 : 14, color: AppTheme.onSurfaceVariant, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildDriverSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: 80,
      ),
      color: AppTheme.surfaceContainer,
      child: isDesktop
          ? Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: _buildDriverImage(isDesktop),
                  ),
                ),
                const SizedBox(width: 80),
                Expanded(flex: 1, child: _buildDriverContent(context, isDesktop)),
              ],
            )
          : Column(
              children: [
                _buildDriverImage(isDesktop),
                const SizedBox(height: 40),
                _buildDriverContent(context, isDesktop),
              ],
            ),
    );
  }

  Widget _buildDriverImage(bool isDesktop) {
    return Container(
      constraints: BoxConstraints(maxWidth: isDesktop ? 500 : double.infinity, maxHeight: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryContainer.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/images/parigo_car_banner.jpg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDriverContent(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Drive With Us',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Earn more while driving green.',
          style: GoogleFonts.nunito(
            fontSize: isDesktop ? 40 : 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Join the Parigo EV fleet and become a part of the electric revolution. '
          'We offer competitive payouts, flexible hours, and an easy-to-use driver app '
          'designed to maximize your earnings.',
          style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryContainer,
                foregroundColor: AppTheme.onPrimaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final url = Uri.parse('mailto:parigoev@gmail.com');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              icon: const Icon(Icons.email),
              label: const Text('Contact Us', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Office Location: Address details coming soon!')),
                );
              },
              icon: const Icon(Icons.business),
              label: const Text('Visit Our Office', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildSustainabilityTracker(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: isDesktop ? 80 : 24),
      color: AppTheme.primary,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 40,
        runSpacing: 40,
        children: [
          _buildStatCounter('100,000+', 'EV Kilometers Driven', Icons.electric_car),
          _buildStatCounter('50,000+', 'KG CO2 Saved', Icons.co2),
          _buildStatCounter('5,000+', 'Happy Riders', Icons.emoji_emotions),
        ],
      ),
    );
  }

  Widget _buildStatCounter(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.onPrimary, size: 48),
        const SizedBox(height: 16),
        Text(value, style: GoogleFonts.audiowide(fontSize: 40, color: AppTheme.onPrimary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 18, color: AppTheme.onPrimary)),
      ],
    );
  }

  Widget _buildFareEstimator(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isDesktop ? 80 : 24),
      color: AppTheme.surfaceContainerHigh,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: Column(
            children: [
              Text('Check Your Fare', style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              const SizedBox(height: 32),
              isDesktop ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Pickup Location',
                        prefixIcon: const Icon(Icons.my_location, color: AppTheme.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.arrow_forward, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Drop-off Location',
                        prefixIcon: const Icon(Icons.location_on, color: AppTheme.error),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ) : Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Pickup Location',
                      prefixIcon: const Icon(Icons.my_location, color: AppTheme.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Drop-off Location',
                      prefixIcon: const Icon(Icons.location_on, color: AppTheme.error),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: AppTheme.onPrimaryContainer,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Estimated Fare: Rs 150 - Rs 200')));
                },
                child: const Text('Estimate Fare', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonials(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isDesktop ? 80 : 24),
      color: AppTheme.background,
      child: Column(
        children: [
          Text('What Our Riders Say', style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
          const SizedBox(height: 60),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _buildReviewCard('Rahul S.', 'The quietest and smoothest ride I have ever had. The driver was very professional.'),
              _buildReviewCard('Priya M.', 'I love that I am reducing my carbon footprint just by taking a taxi. Highly recommended!'),
              _buildReviewCard('Amit K.', 'The scheduled rides feature is a lifesaver for my early morning airport trips.'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReviewCard(String name, String review) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 20)),
          ),
          const SizedBox(height: 16),
          Text('"$review"', style: const TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant, fontStyle: FontStyle.italic, height: 1.5)),
          const SizedBox(height: 24),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: isDesktop ? 80 : 24),
      color: AppTheme.background,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text('Frequently Asked Questions', style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              const SizedBox(height: 40),
              _buildFAQItem('Are all your cars electric?', 'Yes! 100% of the Parigo EV fleet consists of zero-emission electric vehicles like the Tata Xpres-T EV.'),
              _buildFAQItem('Can I schedule a ride in advance?', 'Absolutely. Our app allows you to pre-book rides for airport transfers, meetings, or any time you need guaranteed transport.'),
              _buildFAQItem('How is the fare calculated?', 'Our fares are calculated transparently based on distance and time. There are no hidden fees or excessive surge multipliers.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.outline)),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
        childrenPadding: const EdgeInsets.all(16).copyWith(top: 0),
        children: [
          Text(answer, style: const TextStyle(color: AppTheme.onSurfaceVariant, height: 1.5)),
        ],
      ),
    );
  }
}
