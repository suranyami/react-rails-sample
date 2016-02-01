Post = React.createClass
  rawMarkup: ->
    rawMarkup = marked(this.props.children.toString(), {sanitize: true})
    __html: rawMarkup

  render: ->
    <div className="post">
      <h2 className="postSubject">
        {this.props.subject}
      </h2>
      <span dangerouslySetInnerHTML={this.rawMarkup()} />
    </div>

PostBox = React.createClass
  loadPostsFromServer: ->
    $.ajax
      url: this.props.url
      dataType: 'json'
      cache: false
      
      success: (data) =>
        this.setState
          data: data
          
      error: (xhr, status, err) =>
        console.error(this.props.url, status, err.toString())

  handlePostSubmit: (post) ->
    posts = this.state.data
    # Optimistically set an id on the new post. It will be replaced by an
    # id generated by the server. In a production application you would likely
    # not use Date.now() for this and would have a more robust system in place.
    post.id = Date.now()
    newPosts = posts.concat [post]
    
    this.setState
      data: newPosts
      
    $.ajax
      url: this.props.url
      dataType: 'json'
      type: 'POST'
      data:
        post: post
      success: (data) =>
        this.setState
          data: data

      error: (xhr, status, err) =>
        this.setState
          data: posts
        console.error this.props.url, status, err.toString()
    
  getInitialState: ->
    data: []

  componentDidMount: ->
    this.loadPostsFromServer()
    setInterval this.loadPostsFromServer, this.props.pollInterval

  render: ->
    <div className="postBox">
      <h1>Posts</h1>
      <PostList data={this.state.data} />
      <PostForm onPostSubmit={this.handlePostSubmit} />
    </div>

PostList = React.createClass
  render: ->
    arr = new Array(this.props.data)
    postNodes = arr.map (post) ->
      <Post subject={post.subject} key={post.id}>
        {post.body}
      </Post>

    <div className="postList">
      {postNodes}
    </div>

PostForm = React.createClass
  getInitialState: ->
    subject: ''
    body: ''
    
  handleSubjectChange: (e) ->
    this.setState
      subject: e.target.value
  
  handleTextChange: (e) ->
    this.setState
      body: e.target.value

  handleSubmit: (e) ->
    e.preventDefault()
    subject = this.state.subject.trim()
    body = this.state.body.trim()
    return unless body && subject
    
    this.props.onPostSubmit
      subject: subject
      body: body
    
    this.setState
      subject: ''
      body: ''

  render: ->
    <form className="postForm" onSubmit={this.handleSubmit}>
      <input
        type="text"
        placeholder="Subject..."
        value={this.state.subject}
        onChange={this.handleSubjectChange}
      />
      <input
        type="text"
        placeholder="Say something..."
        value={this.state.body}
        onChange={this.handleTextChange}
      />
      <input type="submit" value="Post" />
    </form>

$(document).on "page:change", ->
  $content = $("#content")
  if $content.length > 0
    component =  <PostBox url="posts.json" pollInterval={2000} />
    ReactDOM.render component, document.getElementById('content')