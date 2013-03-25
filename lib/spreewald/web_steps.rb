# coding: UTF-8

# Most of cucumber-rails' original web steps plus a few of our own. 
#
# Note that cucumber-rails deprecated all its steps quite a while ago with the following
# deprecation notice. Decide for yourself whether you want to use them:
#
# > This file was generated by Cucumber-Rails and is only here to get you a head start
# > These step definitions are thin wrappers around the Capybara/Webrat API that lets you
# > visit pages, interact with widgets and make assertions about page content.
#
# > If you use these step definitions as basis for your features you will quickly end up
# > with features that are:
#
# > * Hard to maintain
# > * Verbose to read
#
# > A much better approach is to write your own higher level step definitions, following
# > the advice in the following blog posts:
#
# > * http://benmabey.com/2008/05/19/imperative-vs-declarative-scenarios-in-user-stories.html
# > * http://dannorth.net/2011/01/31/whose-domain-is-it-anyway/
# > * http://elabs.se/blog/15-you-re-cuking-it-wrong
#

require 'spreewald_support/tolerance_for_selenium_sync_issues'
require 'spreewald_support/path_selector_fallbacks'
require 'spreewald_support/step_fallback'
require 'spreewald_support/custom_matchers'
require 'uri'
require 'cgi'


# You can append 'within [selector]' to any other web step
# Example:
#
#       Then I should see "some text" within ".page_body"
When /^(.*) within (.*[^:])$/ do |nested_step, parent|
  with_scope(parent) { step(nested_step) }
end

# nodoc
When /^(.*) within (.*[^:]):$/ do |nested_step, parent, table_or_string|
  with_scope(parent) { step("#{nested_step}:", table_or_string) }
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit _path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit _path_to(page_name)
end

When /^(?:|I )press "([^"]*)"$/ do |button|
  patiently do
    click_button(button)
  end
end

When /^(?:|I )follow "([^"]*)"$/ do |link|
  patiently do
    click_link(link)
  end
end

# Fill in text field
When /^(?:|I )fill in "([^"]*)" (?:with|for) "([^"]*)"$/ do |field, value|
  patiently do
    fill_in(field, :with => value)
  end
end

# Fill in text field
When /^(?:|I )fill in "([^"]*)" (?:with|for) '(.*)'$/ do |field, value|
  patiently do
    fill_in(field, :with => value)
  end
end

# Select from select box
When /^(?:|I )select "([^"]*)" from "([^"]*)"$/ do |value, field|
  patiently do
    select(value, :from => field)
  end
end

# Check a checkbox
When /^(?:|I )check "([^"]*)"$/ do |field|
  patiently do
    check(field)
  end
end

# Uncheck a checkbox
When /^(?:|I )uncheck "([^"]*)"$/ do |field|
  patiently do
    uncheck(field)
  end
end

# Select a radio button
When /^(?:|I )choose "([^"]*)"$/ do |field|
  patiently do
    choose(field)
  end
end

When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"$/ do |path, field|
  patiently do
    attach_file(field, File.expand_path(path))
  end
end

# Checks that some text appears on the page
#
# Note that this does not detect if the text might be hidden via CSS
Then /^(?:|I )should see "([^"]*)"$/ do |text|
  patiently do
    page.should have_content(text)
  end
end

# Checks that a regexp appears on the page
#
# Note that this does not detect if the text might be hidden via CSS
Then /^(?:|I )should see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)
  patiently do
    page.should have_xpath('//*', :text => regexp)
  end
end

Then /^(?:|I )should not see "([^"]*)"$/ do |text|
  patiently do
    page.should have_no_content(text)
  end
end

Then /^(?:|I )should not see \/([^\/]*)\/$/ do |regexp|
  patiently do
    regexp = Regexp.new(regexp)
    page.should have_no_xpath('//*', :text => regexp)
  end
end


# Checks that an input field contains some value (allowing * as wildcard character)
Then /^the "([^"]*)" field should (not )?contain "([^"]*)"$/ do |label, negate, expected_string|
  patiently do
    field = find_field(label)
    field_value = ((field.tag_name == 'textarea') && field.text.present?) ? field.text.strip : field.value

    field_value.send(negate ? :should_not : :should, contain_with_wildcards(expected_string))
  end
end


# checks that an input field was wrapped with a validation error
Then /^the "([^"]*)" field should have the error "([^"]*)"$/ do |field, error_message|
  patiently do
    element = find_field(field)
    classes = element.find(:xpath, '..')[:class].split(' ')

    form_for_input = element.find(:xpath, 'ancestor::form[1]')
    using_formtastic = form_for_input[:class].include?('formtastic')
    error_class = using_formtastic ? 'error' : 'field_with_errors'

    classes.should include(error_class)

    if using_formtastic
      error_paragraph = element.find(:xpath, '../*[@class="inline-errors"][1]')
      error_paragraph.should have_content(error_message)
    else
      page.should have_content("#{field.titlecase} #{error_message}")
    end
  end
end

Then /^the "([^\"]*)" field should( not)? have an error$/ do |label, negate|
  patiently do
    expectation = negate ? :should_not : :should
    field = find_field(label)
    page.send(expectation, have_css(".field_with_errors ##{field[:id]}"))
  end
end

Then /^the "([^"]*)" field should have no error$/ do |field|
  patiently do
    element = find_field(field)
    classes = element.find(:xpath, '..')[:class].split(' ')
    classes.should_not include('field_with_errors')
    classes.should_not include('error')
  end
end

# nodoc
Then /^the "([^"]*)" checkbox(?: within (.*))? should be checked$/ do |label, parent|
  patiently do
    with_scope(parent) do
      field_checked = find_field(label)['checked']
      field_checked.should be_true
    end
  end
end

# nodoc
Then /^the "([^"]*)" checkbox(?: within (.*))? should not be checked$/ do |label, parent|
  patiently do
    with_scope(parent) do
      field_checked = find_field(label)['checked']
      field_checked.should be_false
    end
  end
end

Then /^the radio button "([^"]*)" should( not)? be (?:checked|selected)$/ do |field, negate|
  patiently do
    page.send((negate ? :has_no_checked_field? : :has_checked_field?), field)
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  patiently do
    fragment = URI.parse(current_url).fragment
    current_path = URI.parse(current_url).path
    current_path << "##{fragment}" if fragment.present?
    current_path.should == _path_to(page_name)
  end
end

# Example:
#
#       I should have the following query string:
#         | locale        | de  |
#         | currency_code | EUR |
#
# Succeeds when the URL contains the given "locale" and "currency_code" params
Then /^(?:|I )should have the following query string:$/ do |expected_pairs|
  patiently do
    query = URI.parse(current_url).query
    actual_params = query ? CGI.parse(query) : {}
    expected_params = {}
    expected_pairs.rows_hash.each_pair{|k,v| expected_params[k] = v.split(',')}

    actual_params.should == expected_params
  end
end

# Open the current Capybara page using the "launchy" gem
Then /^show me the page$/ do
  save_and_open_page
end


# checks for the existance of a input field (given its id or label)
Then /^I should( not)? see a field "([^"]*)"$/ do |negate, name|
  expectation = negate ? :should_not : :should
  patiently do
    begin
      field = find_field(name)
    rescue Capybara::ElementNotFound
      # In Capybara 0.4+ #find_field raises an error instead of returning nil
    end
    field.send(expectation, be_present)
  end
end

# Better way to test for a number of money amount than a `Then I should see`
#
# Checks that there is unexpected minus sign, decimal places etc.
#
# See [here](https://makandracards.com/makandra/1225-test-that-a-number-or-money-amount-is-shown-with-cucumber) for details
Then /^I should( not)? see the (?:number|amount) ([\-\d,\.]+)(?: (.*?))?$/ do |negate, amount, unit|
  no_minus = amount.starts_with?('-') ? '' : '[^\\-]'
  nbsp = " "
  regexp = Regexp.new(no_minus + "\\b" + Regexp.quote(amount) + (unit ? "( |#{nbsp}|&nbsp;)(#{unit}|#{Regexp.quote(HTMLEntities.new.encode(unit, :named))})" :"\\b"))
  expectation = negate ? :should_not : :should
  patiently do
    page.body.send(expectation, match(regexp))
  end
end

# Checks "Content-Type" HTTP header
Then /^I should get a response with content-type "([^\"]*)"$/ do |expected_content_type|
  page.response_headers['Content-Type'].should =~ /\A#{Regexp.quote(expected_content_type)}($|;)/
end

# Checks "Content-Disposition" HTTP header
Then /^I should get a download with filename "([^\"]*)"$/ do |filename|
  page.response_headers['Content-Disposition'].should =~ /filename="#{filename}"$/
end

# Checks that a certain option is selected for a text field
Then /^"([^"]*)" should be selected for "([^"]*)"$/ do |value, field|
  patiently do
    field_labeled(field).find(:xpath, ".//option[@selected = 'selected'][text() = '#{value}']").should be_present
  end
end

Then /^nothing should be selected for "([^"]*)"?$/ do |field|
  patiently do
    select = find_field(field)
    begin
      select.find(:xpath, ".//option[@selected = 'selected']").should be_blank
    rescue Capybara::ElementNotFound
    end
  end
end

# Checks for the presence of an option in a select
Then /^"([^"]*)" should( not)? be an option for "([^"]*)"$/ do |value, negate, field|
  patiently do
    xpath = ".//option[text() = '#{value}']"
    if negate
      begin
        field_labeled(field).find(:xpath, xpath).should_not be_present
      rescue Capybara::ElementNotFound
      end
    else
      field_labeled(field).find(:xpath, xpath).should be_present
    end
  end
end

# Like `Then I should see`, but with single instead of double quotes. In case the string contains quotes as well.
Then /^(?:|I )should see '([^']*)'$/ do |text|
  patiently do
    page.should have_content(text)
  end
end

# Check that the raw HTML contains a string
Then /^I should see "([^\"]*)" in the HTML$/ do |text|
  patiently do
    page.body.should include(text)
  end
end

Then /^I should not see "([^\"]*)" in the HTML$/ do |text|
  patiently do
    page.body.should_not include(text)
  end
end

# Checks that status code is 400..599
Then /^I should see an error$/ do
  (400 .. 599).should include(page.status_code)
end

#nodoc
Then /^the window should be titled "([^"]*)"$/ do |title|
  patiently do
    page.should have_css('title', :text => title)
  end
end

When /^I reload the page$/ do
  case Capybara::current_driver
    when :selenium
      page.execute_script(<<-JAVASCRIPT)
        window.location.reload(true);
      JAVASCRIPT
    else
      visit current_path
  end
end

# Checks that an element is actually visible, also considering styles
# Within a selenium test, the browser is asked whether the element is really visible
# In a non-selenium test, we only check for ".hidden", ".invisible" or "style: display:none"
#
# More details [here](https://makandracards.com/makandra/1049-capybara-check-that-a-page-element-is-hidden-via-css)
Then /^(the tag )?"([^\"]+)" should( not)? be visible$/ do |tag, selector_or_text, negate|
  case Capybara::current_driver
  when :selenium, :webkit
    patiently do
      visibility_detecting_javascript = %[
        (function() {

          var selector = #{tag ? selector_or_text.to_json : "':contains(#{selector_or_text.to_json})'"};
          var jqueryLoaded = (typeof jQuery != 'undefined');

          function findCandidates() {
            if (jqueryLoaded) {
              return $(selector);
            } else {
              return $$(selector);
            }
          }

          function isExactCandidate(candidate) {
            if (jqueryLoaded) {
              return $(candidate).find(selector).length == 0;
            } else {
              return candidate.select(selector).length == 0;
            }
          }

          function elementVisible(element) {
            if (jqueryLoaded) {
              return $(element).is(':visible');
            } else {
              return element.offsetWidth > 0 && element.offsetHeight > 0;
            }
          }

          var candidates = findCandidates();

          for (var i = 0; i < candidates.length; i++) {
            var candidate = candidates[i];
            if (isExactCandidate(candidate) && elementVisible(candidate)) {
              return true;
            }
          }
          return false;

        })();
      ].gsub(/\n/, ' ')
      matcher = negate ? be_false : be_true
      page.evaluate_script(visibility_detecting_javascript).should matcher
    end
  else
    invisibility_detecting_matcher = if tag
      have_css(".hidden, .invisible, [style~=\"display: none\"] #{selector_or_text}")
    else
      have_css('.hidden, .invisible, [style~="display: none"]', :text => selector_or_text)
    end
    expectation = negate ? :should : :should_not # sic
    page.send(expectation, invisibility_detecting_matcher)
  end
end

# Click on some text that might not be a link
When /^I click on "([^\"]+)"$/ do |text|
  matcher = ['*', { :text => text }]
  patiently do
    element = page.find(:css, *matcher)
    while better_match = element.first(:css, *matcher)
      element = better_match
    end
    element.click
  end
end

# Use this step to check external links.
#
# Example:
#
#       Then "Sponsor" should link to "http://makandra.com"
# 
Then /^"([^"]*)" should link to "([^"]*)"$/ do |link_label, target|
  patiently do
    link = find_link(link_label)
    link[:href].should =~ /#{Regexp.escape target}$/
  end
end

# Example:
#
#       Then I should see an element ".page .container"
#
Then /^I should (not )?see an element "([^"]*)"$/ do |negate, selector|
  expectation = negate ? :should_not : :should
  patiently do
    page.send(expectation, have_css(selector))
  end
end

# Checks that the result has content type text/plain
Then /^I should get a text response$/ do
  step 'I should get a response with content-type "text/plain"'
end

# Click a link within an element matching the given selector. Will try to be clever
# and disregard elements that don't contain a matching link.
#
# Example:
#
#       When I follow "Read more" inside any ".text_snippet"
#
When /^I follow "([^"]*)" inside any "([^"]*)"$/ do |label, selector|
  node = find("#{selector} a", :text => label)
  node.click
end

Then /^I should( not)? see "([^"]*)" inside any "([^"]*)"$/ do |negate, text, selector|
  expectation = negate ? :should_not : :should
  page.send(expectation, have_css(selector, :text => text))
end

When /^I fill in "([^"]*)" with "([^"]*)" inside any "([^"]*)"$/ do |field, value, selector|
  containers = all(:css, selector)
  input = nil
  containers.detect do |container|
    input = container.first(:xpath, XPath::HTML.fillable_field(field))
  end
  if input
    input.set(value)
  else
    raise "Could not find an input field \"#{field}\" inside any \"#{selector}\""
  end
end

When /^I confirm the browser dialog$/ do
  page.driver.browser.switch_to.alert.accept
end

When /^I cancel the browser dialog$/ do
  page.driver.browser.switch_to.alert.dismiss
end

When /^I enter "([^"]*)" into the browser dialog$/ do |text|
  alert = page.driver.browser.switch_to.alert
  alert.send_keys(text)
  alert.accept
end

# Checks that these strings are rendered in the given order in a single line or in multiple lines
#
# Example:
#
#       Then I should see in this order:
#         | Alpha Group |
#         | Augsburg    |
#         | Berlin      |
#         | Beta Group  |
#
Then /^I should see in this order:?$/ do |text|
  if text.is_a?(String)
    lines = text.split(/\n/)
  else
    lines = text.raw.flatten
  end
  lines = lines.collect { |line| line.gsub(/\s+/, ' ')}.collect(&:strip).reject(&:blank?)
  pattern = lines.collect(&Regexp.method(:quote)).join('.*?')
  pattern = Regexp.compile(pattern)
  patiently do
    page.find('body').text.gsub(/\s+/, ' ').should =~ pattern
  end
end

# Tests that an input or button with the given label is disabled.
Then /^the "([^\"]*)" (field|button) should( not)? be disabled$/ do |label, kind, negate|
  if kind == 'field'
    element = find_field(label)
  else
    element = find_button(label)
  end
  ["false", "", nil].send(negate ? :should : :should_not, include(element[:disabled]))
end

# Tests that a field with the given label is visible.
Then /^the "([^\"]*)" field should( not)? be visible$/ do |label, negate|
  field = find_field(label)
  expectation = negate ? :should_not : :should
  case Capybara::current_driver
  when :selenium, :webkit
    patiently do
      visibility_detecting_javascript = %[
          (function(){
            var field = $('##{field['id']}');
            return(field.is(':visible'));
          })();
      ].gsub(/\n/, ' ')
      page.evaluate_script(visibility_detecting_javascript).send(expectation, be_true)
    end
  else
    field.send(expectation, be_visible)
  end
end

# Waits for the page to finish loading and AJAX requests to finish.
#
# More details [here](https://makandracards.com/makandra/12139-waiting-for-page-loads-and-ajax-requests-to-finish-with-capybara).
When /^I wait for the page to load$/ do
  if [:selenium, :webkit, :poltergeist].include?(Capybara.current_driver)
    wait_until { page.evaluate_script('$.active') == 0 }
  end
  page.has_content? ''
end

# Performs HTTP basic authentication with the given credentials and visits the given path.
#
# More details [here](https://makandracards.com/makandra/971-perform-http-basic-authentication-in-cucumber).
When /^I perform basic authentication as "([^\"]*)\/([^\"]*)" and go to (.*)$/ do |user, password, page_name|
  path = _path_to(page_name)
  if Capybara::current_driver == :selenium
    visit("http://#{user}:#{password}@#{page.driver.rack_server.host}:#{page.driver.rack_server.port}#{path}")
  else
    authorizers = [
      (page.driver.browser if page.driver.respond_to?(:browser)),
      (self),
      (page.driver)
    ].compact
    authorizer = authorizers.detect { |authorizer| authorizer.respond_to?(:basic_authorize) }
    authorizer.basic_authorize(user, password)
    visit path
  end
end

