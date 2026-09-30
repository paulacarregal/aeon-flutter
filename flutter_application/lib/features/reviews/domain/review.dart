import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String placeName;
  final String address;
  final int rating;
  final String comment;
  final List<String> tags;
  final String spendRange;
  final Timestamp? createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.placeName,
    required this.address,
    required this.rating,
    required this.comment,
    required this.tags,
    required this.spendRange,
    this.createdAt,
  });

  factory Review.fromMap(String id, Map<String, dynamic> map) {
    return Review(
      id: id,
      userId: map['userId'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      placeName: map['placeName'] as String? ?? '',
      address: map['address'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      comment: map['comment'] as String? ?? '',
      tags: List<String>.from(map['tags'] as List? ?? const []),
      spendRange: map['spendRange'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }
}
