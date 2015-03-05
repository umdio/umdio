# TODO: implement controller tests and API endpoint tests
# TODO: when tests are run in the test environment, they should ping the umd.io/api directly

require_relative '../tests/spec_helper'

describe 'Courses Endpoint' do  # Probably should be moved higher up the test ladder. For now!
  url = '/v0/courses'
  enes100_response_string = '{"course_id":"ENES100","name":"Introduction to Engineering Design","dept_id":"ENES","department":"Engineering Science","semester":"201501","credits":"3","grading_method":["Regular","Pass-Fail","Audit"],"core":["PS"],"gen_ed":["DSSP"],"description":"Corequisite: MATH140.Students work as teams to design and build a product using computer software for word-processing, spreadsheet, CAD, and communication skills.","relationships":{"coreqs":["Corequisite: MATH140"],"prereqs":[],"restrictions":[],"restricted_to":[],"credit_only_granted_for":[],"credit_granted_for":[],"formerly":[],"also_offered_as":[]},"sections":["ENES100-0101","ENES100-0201","ENES100-0202","ENES100-0301","ENES100-0302","ENES100-0401","ENES100-0501","ENES100-0502","ENES100-0601","ENES100-0602","ENES100-0801"]}'
  enes100_sections_list = '[{"section_id":"ENES100-0101","course":"ENES100","number":"0101","instructors":["Evandro Valente"],"seats":"30","semester":"201501","meetings":[{"days":"MW","start_time":"10:00am","end_time":"11:50am","building":"JMP","room":"1116","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0201","course":"ENES100","number":"0201","instructors":["Romel Gomez"],"seats":"30","semester":"201501","meetings":[{"days":"TuTh","start_time":"10:00am","end_time":"11:50am","building":"JMP","room":"1116","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0202","course":"ENES100","number":"0202","instructors":["Stephen Kamakaris"],"seats":"25","semester":"201501","meetings":[{"days":"TuTh","start_time":"10:00am","end_time":"11:50am","building":"JMP","room":"1215","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0301","course":"ENES100","number":"0301","instructors":["Jackelyn Lopez Roshwalb"],"seats":"30","semester":"201501","meetings":[{"days":"MW","start_time":"12:00pm","end_time":"1:50pm","building":"JMP","room":"1116","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0302","course":"ENES100","number":"0302","instructors":["Ayush Gupta"],"seats":"30","semester":"201501","meetings":[{"days":"MW","start_time":"12:00pm","end_time":"1:50pm","building":"JMP","room":"1215","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0401","course":"ENES100","number":"0401","instructors":["Stephen Secules"],"seats":"30","semester":"201501","meetings":[{"days":"TuTh","start_time":"12:00pm","end_time":"1:50pm","building":"JMP","room":"1215","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0501","course":"ENES100","number":"0501","instructors":["Evandro Valente"],"seats":"30","semester":"201501","meetings":[{"days":"MW","start_time":"2:00pm","end_time":"3:50pm","building":"JMP","room":"1215","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0502","course":"ENES100","number":"0502","instructors":["Jackelyn Lopez Roshwalb"],"seats":"21","semester":"201501","meetings":[{"days":"MW","start_time":"2:00pm","end_time":"3:50pm","building":"JMP","room":"1116","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0601","course":"ENES100","number":"0601","instructors":["Patrick McAvoy"],"seats":"26","semester":"201501","meetings":[{"days":"TuTh","start_time":"2:00pm","end_time":"3:50pm","building":"JMP","room":"1116","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0602","course":"ENES100","number":"0602","instructors":["Kevin Calabro"],"seats":"12","semester":"201501","meetings":[{"days":"TuTh","start_time":"2:00pm","end_time":"3:50pm","building":"JMP","room":"1215","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]},{"section_id":"ENES100-0801","course":"ENES100","number":"0801","instructors":["Nicholas Wagman"],"seats":"12","semester":"201501","meetings":[{"days":"TuTh","start_time":"4:30pm","end_time":"6:20pm","building":"JMP","room":"1215","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]}]'
  enes100_section_0101 = '{"section_id":"ENES100-0101","course":"ENES100","number":"0101","instructors":["Evandro Valente"],"seats":"30","semester":"201501","meetings":[{"days":"MW","start_time":"10:00am","end_time":"11:50am","building":"JMP","room":"1116","classtype":"Lecture"},{"days":"","start_time":"","end_time":"","building":"","room":"ONLINE","classtype":"Lecture"}]}'
    
  shared_examples_for 'good status' do |url|
    before {head url}
    it 'has a good response' do
      expect(last_response.status).to be == 200
    end
  end

  shared_examples_for 'bad status' do |url|
    before {head url}
    it 'responds with 4xx' do
      expect(last_response.status).to be > 399
      expect(last_response.status).to be < 500
    end
  end

  describe 'Listing courses' do
    shared_examples_for 'get course list' do |url|
      before { get url }
      it 'returns a list of courses' do
        require 'json'
        res = JSON.parse(last_response.body)
        expect(res.length).to be > 4000
        expect(res[5000]).to be == nil
      end
    end

    describe 'GET /courses' do #this test takes most of the time in our test suite right now (80%)
      it_has_behavior 'good status', url
      it_has_behavior 'get course list', url
      it 'returns full objects' do
        require 'json'
        #expect(JSON.parse((get url).body)).to 
      end
    end

    describe 'GET /courses/list' do #list courses with course_id, department, name
      it_has_behavior 'good status', url + '/list'
      it_has_behavior 'get course list', url + '/list'
    end

  end

  describe 'GET /courses/<course_id>' do
    shared_examples_for "gets enes100" do |url|
      before {get url}
      it 'returns enes100 course object' do
        expect(last_response.body).to be == enes100_response_string
      end
    end

    describe 'returns correct object' do
      it_has_behavior "gets enes100", url + '/ENES100' 
    end

    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', url + '/ene12'
      it_has_behavior 'bad status', url + '/enes13'
      it_has_behavior 'bad status', url + '/enes100-0101'
      it_has_behavior 'bad status', url + '/enes100,enes132,BMGT22'
    end

    #tests for case insensitivity can just check status (so long as bad tests give bad status!)
    describe 'Case insensitive' do
      it_has_behavior "good status", url + '/ENES100' 
      it_has_behavior "good status", url + '/enes100'
      it_has_behavior "good status", url + '/Enes100'
      it_has_behavior "good status", url + '/cmsc132h'
    end

    describe 'get multiple courses' do
      it_has_behavior 'good status', url + '/ENES100,ENES102' #doesn't check return, could very well make a good corner case
      it_has_behavior 'good status', url + '/ENES100,ENES102,bmgt220'
    end
  end

  describe 'GET /courses/<course_id>/sections' do
    shared_examples_for 'gets enes100 sections' do |url|
      before { get url }
      it 'returns array of section objects' do
        expect(last_response.body).to be == enes100_sections_list
      end
    end
    
    it_has_behavior 'gets enes100 sections', url + '/enes100/sections'

    describe 'Case insensitive to course_id' do
      it_has_behavior 'good status', url + '/ENES100/sections'
      it_has_behavior 'good status', url + '/enes100/sections'
      it_has_behavior 'good status', url + '/Enes100/sections'
    end
      
    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', url + '/ene12/sections'
      it_has_behavior 'bad status', url + '/enes1000/sections'
    end

  end

  describe 'GET /courses/<course_id>/sections/<section_id>' do
    
    describe 'returns section properly' do
      before {get url + '/enes100/sections/0101'}
      it 'returns the correct section' do
        expect(last_response.body).to be == enes100_section_0101
      end
    end

    describe 'Case insensitive to course_id' do
      it_has_behavior 'good status', url + '/ENES100/sections/0101'
      it_has_behavior 'good status', url + '/Enes100/sections/0101'
      it_has_behavior 'good status', url + '/enes100/sections/0101'
    end

    describe 'handles multiple arguments' do
      before {get url + '/enes100/sections/0101,0201,0202,0301,0302,0401,0501,0502,0601,0602,0801'}
      it 'returns multiple sections to request' do
        expect(last_response.body).to be == enes100_sections_list
      end
    end

    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', url + '/ene12/sections/0101'
      it_has_behavior 'bad status', url + '/enes13/sections/01'
      it_has_behavior 'bad status', url + '/enes13/sections/01011'
      it_has_behavior 'bad status', url + '/enes100/sections/enes100-0101'
      it_has_behavior 'bad status', url + '/enes100/sections/0101,0102,02'
    end

  end

  describe 'GET /courses/sections/<section_id>' do
    describe 'returns section properly' do
      before { get url + '/sections/ENES100-0101'}
      it 'returns the right section' do
          expect(last_response.body).to be == enes100_section_0101        
      end
    end

    describe 'Case insensitive' do
      it_has_behavior 'good status', url + '/sections/ENES100-0101'
      it_has_behavior 'good status', url + '/sections/enes100-0101'
      it_has_behavior 'good status', url + '/sections/Enes100-0101'
    end

    describe 'handles multiple arguments' do
      before {get url + '/sections/ENES100-0101,ENES100-0201,ENES100-0202,ENES100-0301,ENES100-0302,ENES100-0401,ENES100-0501,ENES100-0502,ENES100-0601,ENES100-0602,ENES100-0801'}
      it 'returns multiple sections on request' do
        expect(last_response.body).to be == enes100_sections_list
      end          
    end

    describe 'returns error on misformed urls' do
      it_has_behavior 'bad status', url + '/sections/enes100'
      it_has_behavior 'bad status', url + '/sections/enes100-010'
      it_has_behavior 'bad status', url + '/sections/enes1000101'
      it_has_behavior 'bad status', url + '/sections/enes10-0101'
      it_has_behavior 'bad status', url + '/sections/ene100-0101'
      it_has_behavior 'bad status', url + '/sections/enes100-0101,enes102-010'
    end

  end
end