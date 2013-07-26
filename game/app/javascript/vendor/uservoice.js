(function(){
  var uv = document.createElement('script');
  uv.type = 'text/javascript';
  uv.async = true;
  uv.src = '//widget.uservoice.com/24oEv58YxGW9DZwh3xuCg.js';
  var s = document.getElementsByTagName('script')[0];
  s.parentNode.insertBefore(uv,s)
})();

UserVoice = window.UserVoice || [];

// Identify the user and pass traits
// To enable, replace sample data with actual user traits and uncomment the line
UserVoice.push(['identify',{
  //email:      'john.doe@example.com', // User’s email address
  //name:       'John Doe', // User’s real name
  //created_at: 1364406966, // Unix timestamp for the date the user signed up
  //id:         123, // Optional: Unique id of the user (if set, this should not change)
  //type:       'Owner', // Optional: segment your users by type
  //account: {
  //  id:           123, // Optional: associate multiple users with a single account
  //  name:         'Acme, Co.', // Account name
  //  created_at:   1364406966, // Unix timestamp for the date the account was created
  //  monthly_rate: 9.99, // Decimal; monthly rate of the account
  //  ltv:          1495.00, // Decimal; lifetime value of the account
  //  plan:         'Enhanced' // Plan name for the account
  //}
}]);


UserVoice.push(['set', '__org_name', 'Enhanced Wars']);

// Pin the (?) icon for the contact form w/Instant Answers on your page
UserVoice.push(['pin', 'contact']);

// Autoprompt users for Satisfaction and SmartVote
// (only displayed when certain conditions are met)
UserVoice.push(['autoprompt']);
