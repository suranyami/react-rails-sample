require 'rails_helper'

RSpec.describe "posts/edit", type: :view do
  before(:each) do
    @post = assign(:post, Post.create!(
      :subject => "MyString",
      :body => "MyText"
    ))
  end

  it "renders the edit post form" do
    render

    assert_select "form[action=?][method=?]", post_path(@post), "post" do

      assert_select "input#post_subject[name=?]", "post[subject]"

      assert_select "textarea#post_body[name=?]", "post[body]"
    end
  end
end
