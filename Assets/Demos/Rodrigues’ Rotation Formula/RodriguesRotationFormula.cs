using Unity.XR.CoreUtils;
using UnityEngine;

public class RodriguesRotationFormula
{
    public static Matrix4x4 GetRotationMatrix(float angle, Vector3 axis)
    {
        angle *= Mathf.Deg2Rad;
        Matrix4x4 rotationMatrix;
        axis = axis.normalized;
        var axisV4 = new Vector4(axis.x, axis.y, axis.z, 0);
        var matrixN = new Matrix4x4(new Vector4(0, -axis.z, axis.y, 0), new Vector4(axis.z, 0, -axis.x, 0), new Vector4(-axis.y, axis.x, 0, 0), Vector4.zero);

        var cosValue = Mathf.Cos(angle);

        rotationMatrix = MatrixMultipliedByNumber(Matrix4x4.identity, cosValue);
        rotationMatrix = Matrix4x4PlusMatrix4x4(rotationMatrix, MatrixMultipliedByNumber(ColumnVector4MultipliedByRowVector4(axisV4, axisV4), 1 - cosValue));
        rotationMatrix = Matrix4x4PlusMatrix4x4(rotationMatrix, MatrixMultipliedByNumber(matrixN, Mathf.Sin(angle)));

        return rotationMatrix;
    }

    static Matrix4x4 MatrixMultipliedByNumber(Matrix4x4 matrix, float num)
    {
        for (int i = 0; i < 16; i++)
        {
            matrix[i] *= num;
        }
        return matrix;
    }
    static Matrix4x4 ColumnVector4MultipliedByRowVector4(Vector4 columnVector, Vector4 rowVector)
    {
        var matrix = new Matrix4x4();
        int index = 0;
        for (int i = 0; i < 4; i++)
        {
            for (int j = 0; j < 4; j++)
            {
                matrix[index] = columnVector[j] * rowVector[i];
                index++;
            }
        }
        return matrix;
    }
    static Matrix4x4 Matrix4x4PlusMatrix4x4(Matrix4x4 matrix1, Matrix4x4 matrix2)
    {
        for (int i = 0; i < 16; i++)
        {
            matrix1[i] += matrix2[i];
        }
        return matrix1;
    }
}