Gem::Specification.new do |s|
  s.name        = 'mail_safe-sendgrid'
  s.version     = '0.0.2'
  s.date        = '2012-03-13'
  s.summary     = 'Sendgrid support for Mail Safe'
  s.description = 'Extends Mail Safe to look for and sanitize Sendgrid specific X-SMTPAPI headers'
  s.authors     = ['Ed Shadi', 'Vijay Ramesh']
  s.email       = ['ed@change.org', 'vijay@change.org']
  s.homepage    = 'https://rubygems.org/gems/mail_safe-sendgrid'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'mail_safe'
  s.add_runtime_dependency 'sendgrid'

  s.add_development_dependency 'actionmailer'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'

end
