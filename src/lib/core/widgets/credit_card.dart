import 'package:flutter/material.dart';

class CreditCard extends StatelessWidget {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final bool showBackView;
  final String cvv;

  const CreditCard({
    super.key,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    this.showBackView = false,
    required this.cvv,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586, // Standard credit card ratio
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective effect
          ..rotateY(showBackView ? 3.14159 : 0), // 180 degrees in radians
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[900]!,
                Colors.blue[800]!,
                Colors.blue[700]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: showBackView ? _buildBackView() : _buildFrontView(),
        ),
      ),
    );
  }

  Widget _buildFrontView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network(
                'https://example.com/chip.png', // Replace with actual chip image
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 40,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.amber[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
              const Icon(
                Icons.wifi_rounded,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
          const Spacer(),
          Text(
            _formatCardNumber(cardNumber),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: 2,
              fontFamily: 'monospace',
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CARD HOLDER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cardHolder.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackView() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          height: 48,
          color: Colors.black87,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 40,
                color: Colors.white,
                padding: const EdgeInsets.only(right: 8),
                alignment: Alignment.centerRight,
                child: Text(
                  cvv,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This card is property of RentEase. If found, please return it to the nearest bank branch.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  height: 1.5,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCardNumber(String number) {
    final nums = number.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < nums.length; i += 4) {
      if (i > 0) buffer.write(' ');
      buffer.write(nums.substring(i, i + 4 > nums.length ? nums.length : i + 4));
    }
    return buffer.toString();
  }
}