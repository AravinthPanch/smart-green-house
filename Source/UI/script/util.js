define(function () {
    return {
        calculateBar: function (startTime, endTime) {
            var timeSpan = endTime - startTime
            var currentTime = Date.now()
            var completedTime = moment(currentTime).diff(startTime)
            var barSize = (completedTime / timeSpan) * 100
            return barSize
        }
    }
})
