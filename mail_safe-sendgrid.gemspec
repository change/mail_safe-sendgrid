Gem::Specification.new do |s|
  s.name        = 'mail_safe-sendgrid'
  s.version     = '0.0.0'
  s.date        = '2012-03-12'
  s.summary     = 'Sendgrid support for Mail Safe'
  s.description = 'Extends Mail Safe to look for and santize Sendgrid specific X-SMTPAPI headers'
  s.authors     = ['Ed Shadi', 'Vijay Ramesh']
  s.email       = ['ed@change.org', 'vijay@change.org']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
