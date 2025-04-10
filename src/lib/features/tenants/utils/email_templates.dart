import '../models/tenant.dart';

class EmailTemplates {
  static String getWelcomeEmail(Tenant tenant) {
    return '''
Dear ${tenant.name},

Welcome to your new home! We're excited to have you as a tenant and want to ensure you have everything you need for a comfortable stay.

Important Information:
- Unit Number: ${tenant.unitNumber}
- Lease Period: ${tenant.formattedLeaseStart} to ${tenant.formattedLeaseEnd}
- Monthly Rent: ${tenant.formattedMonthlyRent}

Your tenant portal credentials have been sent in a separate email. Please use these to:
- Make rent payments
- Submit maintenance requests
- Communicate with property management
- Access important documents

Important Contacts:
- Emergency: [Emergency Contact]
- Maintenance: [Maintenance Contact]
- Property Manager: [Manager Contact]

Building Access:
- Main entrance code: [Code]
- Unit keys: Available at the management office
- Parking spot: [Spot Number]

Please review the attached tenant handbook for:
- Building rules and regulations
- Maintenance procedures
- Payment policies
- Amenities guide

If you have any questions or need assistance, don't hesitate to reach out through the tenant portal or contact the property management office.

Welcome again, and we hope you enjoy your new home!

Best regards,
[Property Name] Management Team
''';
  }

  static String getRentReminderEmail(Tenant tenant) {
    return '''
Dear ${tenant.name},

This is a friendly reminder that your monthly rent payment of ${tenant.formattedMonthlyRent} is due on [Due Date].

Payment Details:
- Amount: ${tenant.formattedMonthlyRent}
- Due Date: [Due Date]
- Late Fee: [Late Fee Amount] (applied after [Grace Period])

Payment Methods:
- Online Portal (recommended)
- Mobile Money
- Bank Transfer

To avoid late fees, please ensure your payment is submitted before the due date.

If you have any questions or concerns, please don't hesitate to contact us.

Best regards,
[Property Name] Management Team
''';
  }

  static String getLeaseExpirationEmail(Tenant tenant) {
    return '''
Dear ${tenant.name},

This is to remind you that your lease agreement for Unit ${tenant.unitNumber} is set to expire on ${tenant.formattedLeaseEnd}.

To ensure a smooth transition, please let us know your intentions:
1. Renew your lease
2. Move out at the end of the term

Important Dates:
- Lease End: ${tenant.formattedLeaseEnd}
- Notice Required: [Notice Period] days
- Property Inspection: To be scheduled

If you wish to renew:
- New lease terms will be provided
- Updated rental rate will be discussed
- Renewal documentation will be prepared

If you plan to move out:
- Schedule a move-out inspection
- Return all keys and access cards
- Provide forwarding address
- Review security deposit return process

Please respond within [Response Period] days to confirm your decision.

Thank you for being a valued tenant.

Best regards,
[Property Name] Management Team
''';
  }
}