class FirestoreCollections {
  static const String studentProfiles = 'studentProfiles';
  static const String companyProfiles = 'companyProfiles';
  static const String posts = 'posts';
  static const String applications = 'applications';
  static const String users = 'users';
  static const String defaultProfile = 'default';
  static const String experiences = 'experiences';
}

class FirestoreStudentFields {
  static const String studentId = 'studentId';
  static const String fullName = 'fullName';
  static const String email = 'email';
  static const String university = 'university';
  static const String studentClass = 'class';
  static const String department = 'department';
  static const String startYear = 'startYear';
  static const String graduationYear = 'graduationYear';
  static const String profileImageUrl = 'profileImageUrl';
  static const String aboutMe = 'about';
  static const String skills = 'skills';
  static const String cvUrl = 'cvUrl';
  static const String isProfileComplete = 'isProfileComplete';
  static const String savedPostIds = 'savedPostIds';
}

class FirestoreCompanyFields {
  static const String companyName = 'companyName';
  static const String companyId = 'companyId';
  static const String logoUrl = 'logoUrl';
  static const String location = 'location';
  static const String website = 'website';
  static const String industry = 'industry';
  static const String aboutCompany = 'aboutCompany';
}

class FirestoreUserFields {
  static const String email = 'email';
  static const String role = 'role';
  static const String createdAt = 'createdAt';
  static const String phone = 'phone';
  static const String linkedin = 'linkedin';
  static const String github = 'github';
  static const String address = 'address';
  static const String portfolio = 'portfolio';
}

class FireStoreExperienceFields {
  static const String company = 'company';
  static const String position = 'position';
  static const String description = 'description';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  static const String isCurrent = 'isCurrent';
  static const String createdAt = 'createdAt';
}

class FireStorePostFields {
  static const String postId = 'postId';
  static const String positionTitle = 'positionTitle';
  static const String description = 'description';
  static const String qualifications = 'qualifications';
  static const String location = 'location';
  static const String workType = 'workType';
  static const String internshipType = 'internshipType';
  static const String tags = 'tags';
  static const String createdAt = 'createdAt';
  static const String isActive = 'isActive';
}

class FireStoreApplicationFields {
  static const String applicationId = 'applicationId';
  static const String status = 'status';
  static const String appliedAt = 'appliedAt';
  static const String matchScore = 'matchScore';
  static const String aiExplanation = 'aiExplanation';
}

class FirebaseMessagingTopic {
  static const String notification = 'staj_ilanlari';
}
