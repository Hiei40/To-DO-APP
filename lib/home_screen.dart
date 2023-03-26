import 'package:flutter/material.dart';
import 'package:untitled2todo/db_helper.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  List<Map<String,dynamic>> _allData=[];
 bool _isLoading =true;
 //Get All Data From Database
void _refreshData()async{
  final data=await SQLHelper.getALLData();
setState(() {

  _allData =data;
  _isLoading=false;
});
}
@override
void initState(){
  super.initState();
  _refreshData();
}

 // add data
  Future<void> _addData()async{
    await SQLHelper.createData(_titleController.text, _descController.text);
    _refreshData();
  }
  //update data
  Future<void>_update(int id)async{
    await SQLHelper.updateData(id,_titleController.text,_descController.text);
    _refreshData();
  }
  //delete data
  Future<void> _deleteData(int id) async {
    await SQLHelper.deleteData(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Data Deleted"),
      ),
    );
    _refreshData();
  }
  final TextEditingController _titleController =TextEditingController();
  final TextEditingController _descController =TextEditingController();
  showBottomSheet(int? id) {
    if (id != null) {
      final existingData = _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
    }
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30.0,
          left: 15.0,
          right: 15.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Description",
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addData();
                  }
                  if (id != null) {
                    await _update(id); // call _update() function when editing data
                  }
                  _titleController.text = "";
                  _descController.text = "";
                  Navigator.of(context).pop(); // move this statement inside the if statements
                  print("Data Added/Updated");
                },
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Text(
                    id == null ? "Add Data" : "Update",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text("Todoapp"),
),
      body: _isLoading?
      Center(
        child: CircularProgressIndicator(),):ListView.builder(itemCount:_allData.length ,
      itemBuilder: (context,index)=>Card(
        margin: EdgeInsets.all(15.0),
        child: ListTile(
          title: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
          child:Text(_allData[index]['title'],
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          ),
          subtitle: Text(_allData[index]['desc']),
          trailing:  Row(
            mainAxisSize: MainAxisSize.min ,
            children: [
              IconButton(onPressed: (){
                showBottomSheet(_allData[index]['id']);
              }, icon:Icon(Icons.edit),
                color: Colors.indigo,
              ),
              IconButton(onPressed: (){
              _deleteData(_allData[index]['id']);
              }, icon:Icon(Icons.delete),
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed: ()=>showBottomSheet(null),
  child: Icon(Icons.add),
      ),
    );
  }
}
