namespace :sample do
  desc 'create random posts (destroys any existing)'
  task posts: :environment do
    Post.destroy_all
    10.times do
      post = FactoryGirl.create(:post)
      ap post.subject
    end
  end
end