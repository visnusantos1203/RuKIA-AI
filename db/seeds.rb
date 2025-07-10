# # Clear existing documents
# puts "Deleting all existing documents..."
# Document.destroy_all
# puts "All existing documents deleted."

# sample_documents = [
#   {
#     title: "Company Return Policy",
#     content: "Our return policy is designed to ensure customer satisfaction. Items can be returned within 30 days of purchase with a valid receipt. All items must be in their original condition with tags attached. For online purchases, shipping costs will be refunded only if the return is due to our error. Customized items are non-returnable unless defective. Electronics must be returned within 14 days and cannot be returned if opened unless defective."
#   },
#   {
#     title: "Employee Remote Work Guidelines",
#     content: "Remote work is available to all full-time employees after 90 days of employment. Employees must maintain core hours of 10 AM to 3 PM in their local time zone for meetings and collaboration. A reliable internet connection with minimum 10Mbps speed is required. Remote workers must attend the monthly virtual team meeting and quarterly in-person meetings. Time tracking is required through our project management system. Equipment including laptop and monitor will be provided by the company."
#   },
#   {
#     title: "Product: Smart Home Hub",
#     content: "The SmartLife Hub is our flagship smart home controller. Key features include: Voice control support for Alexa and Google Assistant, Z-Wave and Zigbee protocol support, automated scene creation, energy usage monitoring, and mobile app control. The hub can connect up to 100 devices simultaneously and includes built-in backup battery support for up to 4 hours of operation during power outages. Retail price: $199.99. Available in white and black colors."
#   },
#   {
#     title: "Customer Service Standards",
#     content: "Our customer service representatives must respond to all inquiries within 24 hours. Phone support is available 24/7 for urgent issues. Email responses should be personalized and address all customer concerns. Chat support is available Monday through Friday, 9 AM to 6 PM EST. Escalation to a supervisor is available upon customer request. All customer interactions must be logged in our CRM system with detailed notes."
#   },
#   {
#     title: "Shipping Information",
#     content: "Standard shipping takes 3-5 business days within the continental US. Express shipping (1-2 business days) is available for an additional $15. International shipping is available to select countries and typically takes 7-14 business days. Free shipping is provided on orders over $50. All orders are processed within 24 hours Monday through Friday. Tracking information is automatically sent via email once the order ships. Signature may be required for items valued over $200."
#   },
#   {
#     title: "Product Warranty Terms",
#     content: "All products come with a standard 1-year warranty covering manufacturing defects. Premium products include an extended 3-year warranty. Warranty covers parts and labor for repairs. Accidental damage is not covered unless additional protection plan is purchased. Warranty is transferable to new owners. Battery replacement is covered for the first year only. Registration must be completed within 30 days of purchase to activate warranty coverage."
#   },
#   {
#     title: "Privacy Policy Highlights",
#     content: "We collect only essential customer data needed for order processing and service improvement. Personal information is never sold to third parties. Data is encrypted using industry-standard protocols. Customers can request their data be deleted at any time. Cookie usage is limited to essential website functionality and can be disabled. Marketing emails are opt-in only and can be disabled at any time. We conduct regular security audits to ensure data protection."
#   },
#   {
#     title: "Payment Methods",
#     content: "We accept all major credit cards including Visa, MasterCard, American Express, and Discover. PayPal and Apple Pay are supported for online purchases. Corporate purchase orders are accepted for business accounts. Payment plans are available for purchases over $500 with approved credit. All transactions are processed in USD. International credit cards may incur additional fees from their banks. Bitcoin payments are now accepted for online orders."
#   }
# ]

# puts "Creating sample documents..."

# sample_documents.each_with_index do |doc, index|
#   puts "processing document: #{doc[:title]}"
#   begin
#     # Add a 1 second delay between requests to avoid rate limiting
#     sleep(1) if index > 0

#     Document.create!(doc)
#     puts "Created document: #{doc[:title]}"
#   rescue => e
#     if e.message.include?('429')
#       # If we hit rate limit, wait 2 minutes and retry
#       puts "#{e.message}"
#       puts "Rate limit hit, waiting 2 minutes..."
#       sleep(2.minutes)
#       retry
#     else
#       puts "Error creating document '#{doc[:title]}': #{e.message}"
#     end
#   end
# end

# puts "Seed data creation completed! Created #{Document.count} documents."
