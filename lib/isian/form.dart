import 'package:flutter/material.dart';
import 'package:find_camp/isian/task.dart'; // Import the TaskScreen

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  String? _name, _email, _phoneNumber, _dob, _destinationCountry, _letterType;
  String? _countryCode = '+62'; // Default country code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Form Fams !',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              // Name Field
              Text(
                'Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: 18),
                onChanged: (value) => _name = value,
              ),
              SizedBox(height: 15),

              // Email Field
              Text(
                'Email',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: 18),
                onChanged: (value) => _email = value,
              ),
              SizedBox(height: 15),

              // Phone Number Field
              Text(
                'Phone No.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  // Dropdown for Country Code
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      items: [
                        DropdownMenuItem(value: '+1', child: Text('+1')),
                        DropdownMenuItem(value: '+91', child: Text('+91')),
                        DropdownMenuItem(value: '+44', child: Text('+44')),
                        DropdownMenuItem(value: '+62', child: Text('+62')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _countryCode = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(fontSize: 16),
                      value: _countryCode,
                    ),
                  ),
                  SizedBox(width: 10),

                  // Phone Number Input
                  Expanded(
                    flex: 5,
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(fontSize: 18),
                      onChanged: (value) => _phoneNumber = value,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Date of Birth Field
              Text(
                'Date of Birth',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextField(
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: 18),
                onChanged: (value) => _dob = value,
              ),
              SizedBox(height: 15),

              // Destination Country Field
              Text(
                'Destination Country',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: 18),
                onChanged: (value) => _destinationCountry = value,
              ),
              SizedBox(height: 15),

              // Letter Type Field with Black Text
              Text(
                'Letter Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              DropdownButtonFormField<String>(
                items: [
                  DropdownMenuItem(
                    value: 'Visa',
                    child: Text(
                      'Visa',
                      style: TextStyle(color: Colors.black), // Set black color for the text
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Others',
                    child: Text(
                      'Others',
                      style: TextStyle(color: Colors.black), // Set black color for the text
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _letterType = value;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: 18),
                value: 'Visa',
              ),
              SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8C52FF),
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(50.0),
                  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
