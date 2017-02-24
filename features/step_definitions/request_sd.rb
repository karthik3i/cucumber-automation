
And(/^I navigate to request page$/) do
on(SearchPage).tab_request_element.click
end

And(/^I click create button$/) do
  on(RequestPage).create_button_element.click
end

Then(/^I should see mandatory fields error messages:$/) do |table|
 table.rows.each do |text_ele|
   @current_page.text.upcase.include?(text_ele.first.upcase).should be_true, "The #{text_ele.first}error message hasn't displayed "
end

end

And(/^I enter (own|cross) institution (PUL|CUL|NYPL) to (PUL|CUL|NYPL) mandaory information for (RETRIVAL|EDD|RECALL) request$/) do |txt_own, txt_insti, txt_crossInsti,txt_request_type|

  if txt_request_type != "RECALL"
  @availbale_barcode = get_available_barcode(txt_insti)
  on(SearchPage).tab_request_element.click
  on(RequestPage).txt_itembarcode_element.value = @availbale_barcode
  on(RequestPage).sele_requestinginsti_element.select(txt_crossInsti)
  end

  case txt_request_type
    when 'RETRIVAL'
          on(RequestPage).populate_data(txt_insti)
    when 'EDD'
      on(RequestPage).request_type_element.select('EDD')
      sleep 3
      on(RequestPage).txt_start_page_element.value = '1'
      on(RequestPage).txt_end_page_element.value = '10'
      on(RequestPage).txt_title_element.value = 'Testing'


      case txt_crossInsti
        when 'CUL'
          on(RequestPage).txt_patronbarcode_element.value ='RECAPTST02'
        when 'PUL'
          on(RequestPage).txt_patronbarcode_element.value ='45678912'
        when 'NYPL'
          on(RequestPage).txt_patronbarcode_element.value ='23333097542730'
      end
    when 'RECALL'
      @availbale_barcode = on(RequestPage).get_retrival_barcode
      on(RequestPage).lnk_goback_element.click
      sleep 3
      on(RequestPage).txt_itembarcode_element.value = @availbale_barcode
      on(RequestPage).sele_requestinginsti_element.select(txt_crossInsti)
      on(RequestPage).populate_data(txt_insti)
      on(RequestPage).request_type_element.select('RECALL')
      sleep 2
  end

  case txt_own
    when 'cross'
      case txt_crossInsti
        when 'CUL'
          on(RequestPage).txt_patronbarcode_element.value ='RECAPTST02'
        when 'PUL'
          on(RequestPage).txt_patronbarcode_element.value ='45678912'
        when 'NYPL'
          on(RequestPage).txt_patronbarcode_element.value ='23333097542730'
      end
  end
end

And(/^I click create$/) do
  on(RequestPage).create_button_element.click
  @current_page.wait_until(30, "Create another window hasn't displayed"){on(RequestPage).create_another_request_element.visible?}
  sleep 5
  on(RequestPage).create_another_request_element.click
end

Then(/^I should see request details in request page$/) do

    sleep 5
    on(RequestPage).lnk_searchrequest_element.click
    sleep 2
    on(RequestPage).itembarcode_element.value = @availbale_barcode
    on(RequestPage).btn_search_element.click
    begin
       sleep 15
       @current_page.text.include?(@availbale_barcode).should be_true, "Request hasn't created for barcode #{@availbale_barcode}"
    rescue
      on(RequestPage).itembarcode_element.value = @availbale_barcode
      on(RequestPage).request_status_element.select ('EXCEPTION')
      on(RequestPage).btn_search_element.click
      sleep 10
      @current_page.text.include?(@availbale_barcode).should be_true, "Request hasn't created for barcode #{@availbale_barcode}"
  end
end



def get_available_barcode(txt_institution)
  on(SearchPage).tab_search_element.click
  sleep 2
  on(SearchPage).btn_show_facts_element.click
  sleep 2
  on(SearchPage).click_facts('Out')
  sleep 2
  case txt_institution
    when 'PUL'
      sleep 2
      on(SearchPage).click_facts('NYPL')
      sleep 2
      on(SearchPage).click_facts('Columbia')
      sleep 2
    when 'CUL'
      #on(SearchPage).btn_show_facts_element.click
      sleep 2
      on(SearchPage).click_facts('NYPL')
      sleep 2
      on(SearchPage).click_facts('Princeton')
      sleep 2
    when 'NYPL'
      #on(SearchPage).btn_show_facts_element.click
      sleep 2
      on(SearchPage).click_facts('Columbia')
      sleep 2
      on(SearchPage).click_facts('Princeton')
      sleep 2
  end
  return on(SearchPage).get_valid_barcode
  on(SearchPage).tab_request_element.click
end

And(/^I search RETRIVAL request$/) do
  on(RequestPage).lnk_searchrequest_element.click
  sleep 2

  on(RequestPage).request_status_element.select('RETRIEVAL ORDER PLACED')
  on(RequestPage).btn_search_element.click
  sleep 2
   @barcode = @current_page.text_area_element(:id => 'searchResultRows1.barcode').value

end
And(/^I click cancel button$/) do
  @current_page.button_element(:id => 'cancelButton-1').click
  #@current_page.wait_until(30, "Close button hasn't displayed"){@current_page.button_element(:class => 'close')}
  sleep 10
  @current_page.navigate_to "http://tst-recap.htcinc.com:9091/search"
  sleep 5
  on(SearchPage).txt_search_box_element.value = @barcode
  step "I click search button"
  @current_page.text.upcase.include?(@barcode).should be_true, "Barcode is not availble state"
end