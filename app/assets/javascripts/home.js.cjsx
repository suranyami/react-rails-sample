Comment = React.createClass
  rawMarkup: ->
    rawMarkup = marked(this.props.children.toString(), {sanitize: true})
    __html: rawMarkup

  render: ->
    <div className="comment">
      <h2 className="commentAuthor">
        {this.props.author}
      </h2>
      <span dangerouslySetInnerHTML={this.rawMarkup()} />
    </div>

CommentBox = React.createClass
  loadCommentsFromServer: ->
    $.ajax
      url: this.props.url
      dataType: 'json'
      cache: false
      
      success: (data) =>
        this.setState
          data: data
          
      error: (xhr, status, err) =>
        console.error(this.props.url, status, err.toString())

  handleCommentSubmit: (comment) ->
    comments = this.state.data
    # Optimistically set an id on the new comment. It will be replaced by an
    # id generated by the server. In a production application you would likely
    # not use Date.now() for this and would have a more robust system in place.
    comment.id = Date.now()
    newComments = comments.concat [comment]
    
    this.setState
      data: newComments
      
    $.ajax
      url: this.props.url
      dataType: 'json'
      type: 'POST'
      data: comment
      success: (data) =>
        this.setState
          data: data

      error: (xhr, status, err) =>
        this.setState
          data: comments
        
        console.error this.props.url, status, err.toString()
    
  getInitialState: ->
    data: []

  componentDidMount: ->
    this.loadCommentsFromServer()
    setInterval this.loadCommentsFromServer, this.props.pollInterval

  render: ->
    <div className="commentBox">
      <h1>Comments</h1>
      <CommentList data={this.state.data} />
      <CommentForm onCommentSubmit={this.handleCommentSubmit} />
    </div>

CommentList = React.createClass
  render: ->
    commentNodes = this.props.data.map (comment) ->
      <Comment author={comment.author} key={comment.id}>
        {comment.text}
      </Comment>
        
      <div className="commentList">
        {commentNodes}
      </div>

CommentForm = React.createClass
  getInitialState: ->
    author: ''
    text: ''
    
  handleAuthorChange: (e) ->
    this.setState
      author: e.target.value
  
  handleTextChange: (e) ->
    this.setState
      text: e.target.value

  handleSubmit: (e) ->
    e.preventDefault()
    author = this.state.author.trim()
    text = this.state.text.trim()
    return unless text && author
    
    this.props.onCommentSubmit
      author: author
      text: text
    
    this.setState
      author: ''
      text: ''

  render: ->
    <form className="commentForm" onSubmit={this.handleSubmit}>
      <input
        type="text"
        placeholder="Your name"
        value={this.state.author}
        onChange={this.handleAuthorChange}
      />
      <input
        type="text"
        placeholder="Say something..."
        value={this.state.text}
        onChange={this.handleTextChange}
      />
      <input type="submit" value="Post" />
    </form>

$ ->
  ReactDOM.render ->
    <CommentBox url="/posts" pollInterval={2000} />
    document.getElementById('content')
    