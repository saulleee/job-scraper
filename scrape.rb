require 'csv'
require 'selenium-webdriver'

def scraper(driver, url, company)
  elements = []
  jobs_hash = {}
  regex = /^(?!.*(?:test|senior|manager|lead|principal|staff|devops|sales|solution|support))(?=.*(?:engineer|developer))/i
  keywords = "//*[contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'engineer') or contains(translate(text(), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), 'developer')]"

  driver.get(url)
  elements << driver.find_elements(:xpath, keywords)
  elements.flatten!
  elements.each do |e|
    (jobs_hash[company] ||= [] ) << e.text if e.text.match(regex)
  end

  @jobs << jobs_hash
end

def scrape
  @jobs = []
  options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
  driver = Selenium::WebDriver.for(:chrome, options: options)
  driver.manage.timeouts.implicit_wait = 10

  begin
    # scraper(driver, 'https://thoughtbot.com/jobs#jobs', 'thoughtbot')
  ensure
    driver.quit
  end
end

def csv_export
  scrape

  CSV.open('jobs.csv', 'wb') do |csv|
    csv << ['Company', 'Position']
    unless @jobs.empty?
      @jobs.each do |hash|
        hash.each do |company, list|
          list.each do |job|
            csv << [company, job]
          end
          csv << ['']
        end
      end
    end
  end
end

csv_export
