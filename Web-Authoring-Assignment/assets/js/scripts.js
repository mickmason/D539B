window.onload = function() {

	//Function which retuns a set of product details to be added to each product description element
	//It returns an array of <p> elements containing product information 
	//Called on "Show details" link click in each product description
	function getProductDetails() { 
		/* Single product object */
		var product = {
			prodid: 12345,
			sizes: [6,7,8,9, 10,12, 14,16],
			colours: ["red", "apricot", "mango"],
			delivery: true
		}

		/* 
				Iterate over the product object 
				For each element create a paragraph element and fill it with each detail
		*/
		var details = [] ;
		for (var key in product) {
			//Check which element of the object Im in and write it appropriately
			if (key === "sizes") {
				var arr = product[key] ; //an array
				//Create a <p> element to add to the product details block
				var para = document.createElement("p") ;
				var strong = document.createElement("strong") ;
				strong.appendChild(document.createTextNode("Sizes: "));
				para.appendChild(strong) ;
				for (var i in arr) {
					
					para.appendChild(document.createTextNode(arr[i]+", ")) ;
				}
				details.push(para) ; //Add the para to the details array
			} else if (key === "colours") {
				//Create a <p> element to add to the product details block
				var para = document.createElement("p") ;
				var strong = document.createElement("strong") ;
				strong.appendChild(document.createTextNode("Colours: "));
				para.appendChild(strong) ;
				var arr = product[key] ; //an array
				for (var i in arr) {
					if (i==arr.length-1) {
							para.appendChild(document.createTextNode(arr[i]+".")) ;
					} else {
							para.appendChild(document.createTextNode(arr[i]+", ")) ;	
					}
					
				}
				details.push(para) ; //Add the para to the details array
			} else if (key === "delivery") {
				//Create a <p> element to add to the product details block
				var para = document.createElement("p") ;
				var strong = document.createElement("strong") ;
				strong.appendChild(document.createTextNode("Delivery: "));
				para.appendChild(strong) ;
				if (product[key] == true) {
					para.appendChild(document.createTextNode(" Yep")) ;			
				} else {
					para.appendChild(document.createTextNode(" Nope")) ;
				}
				details.push(para) ;
			} else if (key === "prodid") {
				//Create a <p> element to add to the product details block
				var para = document.createElement("p") ;
				var strong = document.createElement("strong") ;
				strong.appendChild(document.createTextNode("Product ID: "));
				para.appendChild(strong) ;
				para.appendChild(document.createTextNode(product[key])) ;
				details.push(para) ;//Add the <p> to the details array
			}
		}//end for key in product 
		return details ;
	}//end getProductDetails()

	/* Modal window in this scope as it's used in several places  */
	var modalWindow = document.getElementById("modal-window") ;
	var modalWindowClasses = "" ;
	/* 
		Function which loads the required product image in the modal window. 
		It constructs the image url using the data-attribute value of the link that was clicked to open the window
	*/
	function loadImageInModal(imageName) {
		
		var path = "../assets/img/" + imageName + ".jpg" ;
		var modWindowImage = document.getElementById('modal-window-image') ;
		modWindowImage.setAttribute('src', path) ;
	} 
	/* 
		Function which opens and closes the modal window 
		Uses the class attribute on the clicked element to determine what to show in the window - image or one of the forms.
		If it's an image (open-image-modal) then the loadImageInModalFunction is called.
		If it's one of the forms, the form is shown. 
		This is also called by the Cancel button on the forms. 
	*/
	function toggleModalWindow() {
		console.log('toggleImageModal click') ;
		event.preventDefault() ;
		var modalClass = this.getAttribute('class') ;

		if (modalClass === "open-image-modal" || modalClass === "close-modal") {
			modalClass = "has-image" ;			
			/* Call this here then make the modal visible */
			loadImageInModal(this.getAttribute('data-attribute')) ;
		} else if (modalClass === "open-reg-form") {
			modalClass = "open-reg-form" ;			
		} else if (modalClass === "open-login-form") {
			modalClass = "open-login-form" ;			
		}
		//console.log(modalClass) ;
		modalWindowClasses = modalWindow.getAttribute('class') ;

		/* mod window does not have class modalClass .visible */
		if (modalWindowClasses.search(modalClass + " visible") === -1) {
		//	console.log("does not have class modalClass .visible");		
			/* Add the .visible class and the approprate modal window class */
			modalWindowClasses = modalWindowClasses + " " + modalClass + " visible" ;
			/* Also set the modal window in the right location */
			modalWindow.style.top = window.pageYOffset + "px" ;
			/* Then add the classes to the modal window */
			modalWindow.setAttribute('class', modalWindowClasses) ;
		} else if (modalWindowClasses.search(modalClass + ' visible') != -1) {
			/* Reset the class value without .visible class */
			modalWindowClasses = modalWindowClasses.substring(0, modalWindowClasses.search(modalClass + ' visible') -1) ;
			modalWindow.setAttribute('class', modalWindowClasses) ;
		} 
	}

	/* View bigger link on product images */
	var openImageModal = document.getElementsByClassName("open-image-modal") ;
	for (var i = 0; i<openImageModal.length; i++) {
		openImageModal[i].onclick = toggleModalWindow ;
	} 
	/* Close window link used on product images in modal window */

	var closeImageModal = document.getElementById("close-image-modal") ;
	closeImageModal.onclick = toggleModalWindow ;

	var openLoginForm = document.getElementById("open-login-form") ;
	openLoginForm.onclick = toggleModalWindow ;
	
	/* User clicks "Cancel" on login or registration forms */
	var loginReset = document.getElementById("login-reset") ;
	loginReset.onclick = toggleModalWindow ;

	/* User clicks "Cancel" on registration forms */
	var regReset = document.getElementById("reg-reset") ;
	regReset.onclick = toggleModalWindow ;

	var openLoginForm = document.getElementById("open-reg-form") ;
	openLoginForm.onclick = toggleModalWindow ;

	/* 
		Toggle the main navigation visiblity using jQuery 
		Onlick it checks if there is an .open class on the main nav
		If there is not (it's closed) use jQuery to slide the nav down, and add class open
		If it's closed, slide it up and take off the .open class
		Fired by onclick of the mobile menu button in mobile view of the pages
	*/
	//reference to main nav
	var mainNav = document.getElementById('main-nav') ;
	//reference to mob menu button	
	var mobileMenu = document.getElementById('mobile-menu') ;
	//click
	mobileMenu.onclick = function(event) {
		//Classes on the main nav element
		var mainNavClasses = mainNav.getAttribute('class');
		//Is it .open?
		if (mainNavClasses.search('open') === -1) {
			//No, slide it down
			$(mainNav).slideDown(function() {
				//Add .open
				mainNavClasses = mainNavClasses + " open" ;
				mainNav.setAttribute('class', mainNavClasses) ;
			}) ;
			
		} else {
			//Yes it's open, slide it up
			$(mainNav).slideUp(function() {
				//Take off the .open class
				mainNavClasses = mainNavClasses.substring(0, mainNavClasses.search('open')-1) ;
				mainNav.setAttribute('class', mainNavClasses) ;	
			});
		}
	}

	/* 
			Onchange event on colour selector select element in product info blocks 
			Pops up an alert showing the colour selected
	*/
	//An array of select elements
	var prodColour = document.getElementsByClassName("product-color") ;
	//For each
	for (var h in prodColour) {
		//Add a change handler
		prodColour[h].onchange = function() {
			//Alert a response to this.value 
			if (this.value !== "default") {
				alert("You selected "+ this.value+" . Well done.") ;
			} else {
				alert("Please select and actual colour!") ;
			}
		}
	}

	/* On click on "Show details" link in product descriptions */
	/* 
		This goes to the parent .product-info node, then down to the .prod-details box which is hidden by default.
		If the box is hidden, the contents of the box are removed, it calls getProductDetails(), iterates over the returned array 
		and appends each <p> in the array to the .prod-details box.
		Then uses jQuery to slide the box down and add the .visible class to shown that the box is open.
		If it's not hidden, it slides the box up and removes the .visible class.

	
	*/
	var prodDetails = document.getElementsByClassName("show-prod-details") ;
	for (var i in prodDetails) {
		prodDetails[i].onclick = function(event) {
			event.preventDefault() ;
			
			//I use the $ to indicate a 'live' DOM element
			var $prodDetailsBox = this.parentNode.parentNode.getElementsByClassName("prod-details")[0] ;

			//IF the box is hidden
			if ($prodDetailsBox.getAttribute("class").search("visible") == -1){
				//Clear out any <p>s in the box	
				for (var j=0;j<=$prodDetailsBox.childNodes.length; j++) {
					if ($prodDetailsBox.querySelector('p') != null) {
							$prodDetailsBox.removeChild($prodDetailsBox.querySelector('p')) ;	
					}	
				}
				var paras = getProductDetails() ;
				//console.log(paras) ;
				for (k in paras) {
					$prodDetailsBox.appendChild(paras[k]) ;
				}
				//Slide down the box and add class .visible
				$($prodDetailsBox).slideDown(function() {
						$prodDetailsBox.setAttribute("class", $prodDetailsBox.getAttribute("class") + " visible") ;	
				} ) ;
			} else {
				for (var j=0;j<=$prodDetailsBox.childNodes.length; j++) {
					if ($prodDetailsBox.querySelector('p') != null) {
							$prodDetailsBox.removeChild($prodDetailsBox.querySelector('p')) ;	
					}	
				}
				var classes = $prodDetailsBox.getAttribute("class") ;
				
				$($prodDetailsBox).slideUp(function() {
					$prodDetailsBox.setAttribute("class", classes.substring(0, classes.search(" visible")));
				}) ;
			}
		}
	}

}