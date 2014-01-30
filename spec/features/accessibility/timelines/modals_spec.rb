#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'
require 'features/timelines/timelines_page'

describe 'Timelines modal accessibility' do
  let(:project) { FactoryGirl.create(:project) }
  let(:current_user) { FactoryGirl.create(:admin) }
  let(:timelines) { FactoryGirl.create(:timelines, project_id: project.id) }
  let(:timelines_page) { TimelinesPage.new }

  before { User.stub(:current).and_return current_user }

  def active_element
    page.evaluate_script("document.activeElement.id")
  end

  def tab(direction = :forward)
    #find('body').send_keys(((direction == :backward) ? :shift : nil), :tab)
    find('body').base.invoke('keypress', false, false, false, false, 9, nil)
    #keypress_script = "var e = jQuery.Event('keydown', { keyCode: 9#{(direction == :backward) ? ", shiftKey" : ""} }); jQuery('body').trigger(e);"
    #puts keypress_script
    #page.driver.browser.execute_script(keypress_script)
  end

  shared_context 'load work package modal' do
    let(:add_work_package_button) { find(".tl-toolbar a.icon.icon-add") }
    let(:browser) { page.driver.browser }

    before do
      timelines_page.visit_show timelines.project_id, timelines.id

      find("table.tl-main-table") # wait for timelines to finish load

      add_work_package_button.click

      expect(page).to have_selector("#modalDiv")

      browser.switch_to.frame("modalIframe")
    end

    after { browser.switch_to.default_content }
  end

  describe 'work package modal', js: true do
    include_context 'load work package modal'

    before do
      Capybara.current_driver = :webkit 
    end

    after do
      Capybara.use_default_driver
    end

    describe 'next focused element' do
      before { tab }

      it { expect(active_element).to eq("work_package_type_id") }
    end

    describe 'previous focused element' do
      before do
        tab
        tab(:backward)
        tab(:backward)
      end

      it { expect(active_element).to eq("work_package-form-preview") }
    end
  end
end
