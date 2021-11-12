------------------------------------------------------------------------------
--                                                                          --
--                                 Langkit                                  --
--                                                                          --
--                     Copyright (C) 2014-2021, AdaCore                     --
--                                                                          --
-- Langkit is free software; you can redistribute it and/or modify it under --
-- terms of the  GNU General Public License  as published by the Free Soft- --
-- ware Foundation;  either version 3,  or (at your option)  any later ver- --
-- sion.   This software  is distributed in the hope that it will be useful --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY  or  FITNESS  FOR A PARTICULAR PURPOSE.                         --
--                                                                          --
-- As a special  exception  under  Section 7  of  GPL  version 3,  you are  --
-- granted additional  permissions described in the  GCC  Runtime  Library  --
-- Exception, version 3.1, as published by the Free Software Foundation.    --
--                                                                          --
-- You should have received a copy of the GNU General Public License and a  --
-- copy of the GCC Runtime Library Exception along with this program;  see  --
-- the files COPYING3 and COPYING.RUNTIME respectively.  If not, see        --
-- <http://www.gnu.org/licenses/>.                                          --
------------------------------------------------------------------------------

with Langkit_Support.Internal.Analysis; use Langkit_Support.Internal.Analysis;
with Langkit_Support.Internal.Conversions;
use Langkit_Support.Internal.Conversions;
with Langkit_Support.Internal.Descriptor;
use Langkit_Support.Internal.Descriptor;

package body Langkit_Support.Internal.Introspection is

   function Builtin_Types
     (Value : Internal_Value'Class) return Builtin_Types_Access;
   --  Return the list of type indexes for all builtin types according to
   --  ``Value``'s language.

   -------------------
   -- Builtin_Types --
   -------------------

   function Builtin_Types
     (Value : Internal_Value'Class) return Builtin_Types_Access
   is
      Desc : constant Language_Descriptor_Access := +Value.Id;
   begin
      return Desc.Builtin_Types;
   end Builtin_Types;

   ------------------
   -- Type_Matches --
   ------------------

   function Type_Matches
     (Value : Internal_Value; T : Type_Index) return Boolean is
   begin
      return Internal_Value'Class (Value).Type_Of = T;
   end Type_Matches;

   ---------
   -- "=" --
   ---------

   overriding function "="
     (Left, Right : Internal_Rec_Analysis_Unit) return Boolean is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of
     (Value : Internal_Rec_Analysis_Unit) return Type_Index is
   begin
      return Builtin_Types (Value).Analysis_Unit;
   end Type_Of;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Internal_Rec_Analysis_Unit) return String
   is
   begin
      if Value.Value = No_Lk_Unit then
         return "<No analysis unit>";
      else
         return "<Unit for " & Value.Value.Filename & ">";
      end if;
   end Image;

   ---------
   -- "=" --
   ---------

   overriding function "=" (Left, Right : Internal_Rec_Big_Int) return Boolean
   is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of (Value : Internal_Rec_Big_Int) return Type_Index
   is
   begin
      return Builtin_Types (Value).Big_Int;
   end Type_Of;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Internal_Rec_Big_Int) return String
   is
   begin
      return "BigInt(" & GNATCOLL.GMP.Integers.Image (Value.Value) & ")";
   end Image;

   ---------
   -- "=" --
   ---------

   overriding function "=" (Left, Right : Internal_Rec_Bool) return Boolean is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of (Value : Internal_Rec_Bool) return Type_Index
   is
   begin
      return Builtin_Types (Value).Bool;
   end Type_Of;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Internal_Rec_Bool) return String is
   begin
      return (if Value.Value then "True" else "False");
   end Image;

   ---------
   -- "=" --
   ---------

   overriding function "="
     (Left, Right : Internal_Rec_Character) return Boolean is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of
     (Value : Internal_Rec_Character) return Type_Index is
   begin
      return Builtin_Types (Value).Char;
   end Type_Of;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Internal_Rec_Character) return String is
   begin
      return "'" & Image (Text_Type'(1 => Value.Value)) & "'";
   end Image;

   ---------
   -- "=" --
   ---------

   overriding function "=" (Left, Right : Internal_Rec_Int) return Boolean is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of (Value : Internal_Rec_Int) return Type_Index is
   begin
      return Builtin_Types (Value).Int;
   end Type_Of;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Internal_Rec_Int) return String is
      Result : constant String := Value.Value'Image;
   begin
      return (if Result (Result'First) = ' '
              then Result (Result'First + 1 ..  Result'Last)
              else Result);
   end Image;

   ---------
   -- "=" --
   ---------

   overriding function "="
     (Left, Right : Internal_Rec_Source_Location_Range) return Boolean is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of
     (Value : Internal_Rec_Source_Location_Range) return Type_Index is
   begin
      return Builtin_Types (Value).Source_Location_Range;
   end Type_Of;

   -----------
   -- Image --
   -----------

   overriding function Image
     (Value : Internal_Rec_Source_Location_Range) return String is
   begin
      return Image (Value.Value);
   end Image;

   ---------
   -- "=" --
   ---------

   overriding function "=" (Left, Right : Internal_Rec_String) return Boolean
   is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of (Value : Internal_Rec_String) return Type_Index
   is
   begin
      return Builtin_Types (Value).String;
   end Type_Of;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Internal_Rec_String) return String is
   begin
      return Image (To_Text (Value.Value), With_Quotes => True);
   end Image;
   ---------
   -- "=" --
   ---------

   overriding function "=" (Left, Right : Internal_Rec_Token) return Boolean is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of (Value : Internal_Rec_Token) return Type_Index
   is
   begin
      return Builtin_Types (Value).Token;
   end Type_Of;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Internal_Rec_Token) return String is
   begin
      return Image (Value.Value);
   end Image;

   ---------
   -- "=" --
   ---------

   overriding function "=" (Left, Right : Internal_Rec_Symbol) return Boolean
   is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of (Value : Internal_Rec_Symbol) return Type_Index
   is
   begin
      return Builtin_Types (Value).Symbol;
   end Type_Of;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Internal_Rec_Symbol) return String is
   begin
      return "Symbol(" & Image (To_Text (Value.Value), With_Quotes => True)
             & ")";
   end Image;

   ---------
   -- "=" --
   ---------

   overriding function "=" (Left, Right : Internal_Rec_Node) return Boolean is
   begin
      return Left.Value = Right.Value;
   end "=";

   -------------
   -- Type_Of --
   -------------

   overriding function Type_Of (Value : Internal_Rec_Node) return Type_Index is
      Desc : constant Language_Descriptor_Access := +Value.Id;
   begin
      if Value.Value = No_Lk_Node then
         return Desc.First_Node;
      else
         declare
            Entity : constant Internal_Entity :=
              Unwrap_Node (Value.Value);
         begin
            return Desc.Node_Kind.all (Entity.Node);
         end;
      end if;
   end Type_Of;

   ------------------
   -- Type_Matches --
   ------------------

   overriding function Type_Matches
     (Value : Internal_Rec_Node; T : Type_Index) return Boolean
   is
      Expected_Type : constant Type_Ref := From_Index (Value.Id, T);
   begin
      --  A node value never matches a non-node type

      if not Is_Node_Type (Expected_Type) then
         return False;
      end if;

      --  The null node matches all node types. Otherwise, the type of
      --  ``Value`` must derive from ``T``.

      if Value.Value = No_Lk_Node then
         return True;
      else
         declare
            Actual_Type : constant Type_Ref :=
              From_Index (Value.Id, Value.Type_Of);
         begin
            return Is_Derived_From (Actual_Type, Expected_Type);
         end;
      end if;
   end Type_Matches;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Internal_Rec_Node) return String is
   begin
      if Value.Value = No_Lk_Node then
         return "<No node>";
      else
         return Image (Value.Value);
      end if;
   end Image;

   -----------
   -- Image --
   -----------

   overriding function Image (Value : Base_Internal_Array_Value) return String
   is
      V : Base_Internal_Array_Value'Class renames
        Base_Internal_Array_Value'Class (Value);
      T : constant Type_Ref := From_Index (V.Id, V.Type_Of);
   begin
      return "Array of" & V.Array_Length'Image & " "
             & Debug_Name (Array_Element_Type (T)) & " elements";
   end Image;

   ---------
   -- "=" --
   ---------

   overriding function "="
     (Left, Right : Base_Internal_Struct_Value) return Boolean
   is
      pragma Unreferenced (Left, Right);
   begin
      --  TODO??? Implement once structs are fully implemented

      return False;
   end "=";

   -----------
   -- Image --
   -----------

   overriding function Image
     (Value : Base_Internal_Struct_Value) return String
   is
      V : Base_Internal_Struct_Value'Class renames
        Base_Internal_Struct_Value'Class (Value);
      T : constant Type_Ref := From_Index (V.Id, V.Type_Of);
   begin
      --  TODO??? Complete once structs are fully implemented

      return Debug_Name (T);
   end Image;

end Langkit_Support.Internal.Introspection;
