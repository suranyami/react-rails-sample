@InfoBox = React.createClass
  render: ->
    <tr className="infoBox">
      <td className="semitone">
        {this.props.semitone}
      </td>
      <td className="multiplier">
        {this.props.multiplier}
      </td>
      <td className="frequency">
        {this.props.frequency}
      </td>
    </tr>

A4 = 440
octave = 4
numFormat = '0,0.0'

semitoneOf = (baseFreq, num) ->
  exponent = num / 12.0
  multiplier = Math.pow(2.0, exponent)
  freq = baseFreq * multiplier
  frequency: freq
  freqString: numeral(freq).format(numFormat)
  multiplier: numeral(multiplier).format('0,0.000')

@BaseFrequency = React.createClass
  getInitialState: ->
    frequency: A4
  
  change: (e) ->
    e.preventDefault()
    frequency = e.target.value
    @setState
      frequency: frequency
    
    this.props.onFrequencyChange(frequency)
  
  render: ->
    <form className="frequencyForm" onSubmit={this.change}>
      <input type="text" placeholder="Base frequency" value={this.state.frequency} onChange={this.change}/>
    </form>

@ScaleBox = React.createClass
  getInitialState: ->
    frequency: A4

  handleFrequencyChange: (frequency) ->
    this.setState
      frequency: frequency
    
  render: ->
    semitones = [0..12]
    freq = this.state.frequency
    notes = semitones.map (note) ->
      data = semitoneOf(freq, note)
      <InfoBox semitone={note} multiplier={data.multiplier} frequency={data.freqString} key={note}/>
    <div>
      <BaseFrequency onFrequencyChange={this.handleFrequencyChange}/>
      <table className="scaleBox">
        <thead>
          <tr>
            <th>Semitone</th>
            <th className="multiplier">Multiplier</th>
            <th className="frequency">Frequency</th>
          </tr>
        </thead>
        <tbody>
          {notes}
        </tbody>
      </table>
    </div>
  

$(document).on "page:change", ->
  $content = $("#content")
  if $content.length > 0
    component = <ScaleBox/>
    ReactDOM.render component, document.getElementById('content')
