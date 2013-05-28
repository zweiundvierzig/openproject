#encoding: utf-8

#-- copyright
# OpenProject is a project management system.
#
# Copyright (C) 2012-2013 the OpenProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

def parse_password_rules(str)
  str.sub(', and ', ', ').split(', ')
end

Given /^passwords must contain ([0-9]+) of ([a-z, ]+) characters$/ do |minimum_rules, rules|
  rules = parse_password_rules(rules)
  Setting.password_active_rules = rules
  Setting.password_min_adhered_rules = minimum_rules.to_i
end

Given /^passwords have a minimum length of ([0-9]+) characters$/ do |minimum_length|
  Setting.password_min_length = minimum_length
end

Given /^users are not allowed to reuse the last ([0-9]+) passwords$/ do |count|
  Setting.password_count_former_banned = count
end

def fill_change_password(old_password, new_password, confirmation=new_password)
  # use find and set with id to prevent ambigious match I get with fill_in
  find('#password').set(old_password)

  fill_in('new_password', :with => new_password)
  fill_in('new_password_confirmation', :with => confirmation)
  click_link_or_button 'Apply'
  @new_password = new_password
end

def change_password(old_password, new_password)
  visit "/my/password"
  fill_change_password(old_password, new_password)
end

Given /^I try to change my password from "([^\"]+)" to "([^\"]+)"$/ do |old, new|
  change_password(old, new)
end

When /^I try to set my new password to "(.+)"$/ do |password|
  visit "/my/password"
  change_password('adminADMIN!', password)
end

When /^I fill out the change password form$/ do
  fill_change_password('adminADMIN!', 'adminADMIN!New')
end

When /^I fill out the change password form with a wrong old password$/ do
  fill_change_password('wrong', 'adminADMIN!New')
end

When /^I fill out the change password form with a wrong password confirmation$/ do
  fill_change_password('adminADMIN!', 'adminADMIN!New', 'wrong')
end

Then /^the password change should succeed$/ do
  find('.notice').should have_content('success')
end

Then /^I should be able to login using the new password$/ do
  visit('/logout')
  login(@user.login, @new_password)
end

Given /^I try to log in with user "([^"]*)"$/ do |login|
  step 'I go to the logout page'
  login(login, @new_password || 'adminADMIN!')
end

Given /^I try to log in with user "([^"]*)" and a wrong password$/ do |login|
  step 'I go to the logout page'
  login(login, 'Wrong password')
end

When /^I activate the ([a-z, ]+) password rules$/ do |rules|
  rules = parse_password_rules(rules)
  # ensure checkboxes are loaded, 'all' doesn't wait
  should have_selector(:xpath, "//input[@id='settings_password_active_rules_' and @value='#{rules.first}']")

  all(:xpath, "//input[@id='settings_password_active_rules_']").each do |checkbox|
    checkbox.set(false)
  end
  rules.each do |rule|
    find(:xpath, "//input[@id='settings_password_active_rules_' and @value='#{rule}']").set(true)
  end
end

def set_user_attribute(login, attribute, value)
  user = User.find_by_login login
  user.send((attribute.to_s + '=').to_sym, value)
  user.save
end

Given /^the user "(.+)" is(not |) forced to change his password$/ do |login, disable|
  set_user_attribute(login, :force_password_change, (disable == 'not ') ? false : true)
end
