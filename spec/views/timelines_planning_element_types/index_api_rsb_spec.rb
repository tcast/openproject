require File.expand_path('../../../spec_helper', __FILE__)

describe 'timelines/timelines_planning_element_types/index.api.rsb' do
  before do
    view.extend TimelinesHelper
  end

  before do
    params[:format] = 'xml'
  end

  describe 'with no planning element types available' do

    it 'renders an empty planning_element_types document' do
      assign(:planning_element_types, [])

      render

      response.should have_selector('planning_element_types', :count => 1)
      response.should have_selector('planning_element_types[type=array][size="0"]') do
        without_tag 'planning_element_type'
      end
    end
  end

  describe 'with 3 planning element types available' do
    let(:planning_element_types) do
      [
        FactoryGirl.build(:timelines_planning_element_type),
        FactoryGirl.build(:timelines_planning_element_type),
        FactoryGirl.build(:timelines_planning_element_type)
      ]
    end

    it 'renders a planning_element_types document with the size 3 of type array' do
      assign(:planning_element_types, planning_element_types)

      render

      response.should have_selector('planning_element_types', :count => 1)
      response.should have_selector('planning_element_types[type=array][size="3"]')
    end

    it 'renders a planning_element_type for each assigned planning element' do
      assign(:planning_element_types, planning_element_types)

      render

      response.should have_selector('planning_element_types planning_element_type', :count => 3)
    end

    it 'renders the _planning_element_type template for each assigned planning element type' do
      assign(:planning_element_types, planning_element_types)

      view.should_receive(:render).exactly(3).times.with(hash_including(:partial => '/timelines/timelines_planning_element_types/planning_element_type.api')).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template=>"timelines/timelines_planning_element_types/index", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end

    it 'passes the planning element types as local var to the partial' do
      assign(:planning_element_types, planning_element_types)

      view.should_receive(:render).once.with(hash_including(:object => planning_element_types.first)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => planning_element_types.second)).and_return('')
      view.should_receive(:render).once.with(hash_including(:object => planning_element_types.third)).and_return('')

      # just to render the speced template despite the should receive expectations above
      view.should_receive(:render).once.with({:template=>"timelines/timelines_planning_element_types/index", :handlers=>["rsb"], :formats=>["api"]}, {}).and_call_original

      render
    end
  end
end