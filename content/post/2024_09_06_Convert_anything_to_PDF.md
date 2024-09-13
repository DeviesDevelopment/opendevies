+++
title = 'Convert anything to PDF'
date = 2024-09-06T09:22:43+02:00
draft = false
showonlyimage = true
image = "img/posts/convert_to_pdf.png"
writer = "Peter Makra"
categories = [ "web", "files" ]
weight = 1
tags = [ "docker", "office", "pdf", "convert", "api", "node" ]
+++



### Try it out
<div style="background: #d6d5d4; padding: 10px; margin: 5px; box-shadow: 2px 2px 2px gray; border-radius: 3px; font-weight: bold"> 
<form id="demo-form">
    <ol>
        <li>
            Choose a file <input id="upload-file" type="file">
        </li>
        <li>
            <span>Enter the result of the calculation with numbers before clicking convert.</span>
            <br />
            <span id="simple-captcha"></span>
            <input style="padding: 0; min-height: 5px; width: 50px; line-height: 1" id="captcha-answer" type="text">
        </li>
        <li>
            <span>Click convert -></span>
            <input style="padding: 0" id="send-file" type="button" value="Convert" onclick="onSubmit()"/>
        </li>
        <li>
            <span>Get your pdf</span>
        </li>
        <li>
            <span>Be happy :)</span>
        </li>
    </ol>
</form>
</div>

<script src="https://www.google.com/recaptcha/api.js"></script>
<script>
    function onSubmit() {
        if ($('input#captcha-answer').val() == window.buzievagy) {
            // todo call api download pdf
            console.log('approved')
            var reader = new FileReader();
            reader.onload = event => {
                var form = new FormData();
                form.append("document", $('#upload-file').prop('files')[0]);
                $.ajax({ 
                    url: 'https://x-foss-convertopdf.whitetree-d4666f7f.northeurope.azurecontainerapps.io/topdf',
                    data: form,
                    cache: false,
                    contentType: false,
                    mimeType: "multipart/form-data",
                    processData: false,
                    method: 'POST',
                    type: 'POST',
                    xhrFields: {
                        responseType: 'blob'
                    },
                    success: function(blob, status, xhr) {                        
                        var filename = "converted.pdf";                       

                       
                        var URL = window.URL || window.webkitURL;
                        var downloadUrl = URL.createObjectURL(blob);
                        // use HTML5 a[download] attribute to specify filename
                        var a = document.createElement("a");
                        // safari doesn't support this yet
                        if (typeof a.download === 'undefined') {
                            window.location.href = downloadUrl;
                        } else {
                            a.href = downloadUrl;
                            a.download = filename;
                            document.body.appendChild(a);
                            a.click();
                        }                        

                        setTimeout(function () { URL.revokeObjectURL(downloadUrl); }, 100); // cleanup                        
                    }
                })
            }
            reader.readAsText($('#upload-file').prop('files')[0]);
        }
    }
    document.addEventListener("DOMContentLoaded", function() {
        var numbers = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
        var operands = ["+", "-", "*"]
        var left = Math.floor(Math.random()*10)
        var right = Math.floor(Math.random()*10)
        var op = operands[Math.floor(Math.random()*3)]
        window.buzievagy = eval(`${left} ${op} ${right}`)
        $('span#simple-captcha').text(`${numbers[left]} ${op} ${numbers[right]} =`)
    });
</script>
<button class="g-recaptcha"
        style="display: none"
        data-sitekey="6LcZkD0qAAAAAHkQkStv2njGkKuk-aoTWDBK5frg" 
        data-action='submit'></button>

> Be aware that the deployed demo instance is with minimal resources. 
If it does not work it may be maxxed out, or scaled to zero.
In the second case after few seconds it should work again.
In the first.. well stop ddosing pls.


### tl;dr for the curious ones
Resources:
- <a href="https://github.com/mcraa/libre-to-pdf-node"  class="github" target="_blank">
    <i class="fab fa-github" title="github"></i>
    <span class="screen-reader-text">github logo</span>
    mcraa/libre-to-pdf-node</a>
- <a href="https://hub.docker.com/r/mcraa/libre-to-pdf-node"  class="github" target="_blank">
    <i class="fab fa-docker" title="docker"></i>
    <span class="screen-reader-text">docker logo</span>
    docker pull mcraa/libre-to-pdf-node</a>
- special thanks to [Libre office](https://www.libreoffice.org/) as most of the work is done by them.
- as well as to the creator of the node<i class="fab fa-node-js" title="nodejs"></i> lib used [<i class="fab fa-npm" title="npm"></i> office-to-pdf](https://www.npmjs.com/package/office-to-pdf?activeTab=readme)

#### So what is added here?

Simple web server created with one endpoint making that CLI command happening.
So you can use it with one click.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgist.githubusercontent.com%2Fmcraa%2Ffc199581ecee2ccdb69699d5b66f70d4%2Fraw%2Fe6c87b7485404bdf84230b8b84ca1e7474b94e07%2Farmtemplate-container-pdfconverter.json)

Or one `docker run`.
Or simply adding it to a kubernetes cluster.
You choose your cup of tea.

#### Background story

Recently a client who handles documents with sensitive data on their web application
wanted to have previews online of all the files uploaded.
My colleague quickly realized converting to PDF is the way to go,
but all solutions he quickly found were sending the file to an unknown thirdparty blackbox.
Which was not acceptable of course.

Luckily a very similar problem existed years ago (just check the commit date in the repo).
Search on docker hub improved since then, while writing this I found a similar solution 4 years older.

So we added a container to the clients cluster, the files never leave our solution, and all files can have preview now as the browser handles pdf easily.